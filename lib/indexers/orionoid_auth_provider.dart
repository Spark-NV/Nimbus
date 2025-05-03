import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'orionoid_api_service.dart';
import 'orionoid_auth_response.dart';

final logger = Logger();

enum OrionoidAuthStatus {
  idle,
  starting,
  waiting,
  approved,
  failed,
}

class OrionoidAuthState {
  final OrionoidAuthStatus status;
  final OrionoidAuthResponse? authResponse;
  final String? errorMessage;
  final DateTime? expirationTime;
  final int pollingInterval;

  OrionoidAuthState({
    this.status = OrionoidAuthStatus.idle,
    this.authResponse,
    this.errorMessage,
    this.expirationTime,
    this.pollingInterval = 5,
  });

  OrionoidAuthState copyWith({
    OrionoidAuthStatus? status,
    OrionoidAuthResponse? authResponse,
    String? errorMessage,
    DateTime? expirationTime,
    int? pollingInterval,
  }) {
    return OrionoidAuthState(
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      expirationTime: expirationTime ?? this.expirationTime,
      pollingInterval: pollingInterval ?? this.pollingInterval,
    );
  }
}

class OrionoidAuthNotifier extends StateNotifier<OrionoidAuthState> {
  final OrionoidApiService _apiService;
  Timer? _pollingTimer;
  Timer? _expirationTimer;

  OrionoidAuthNotifier(this._apiService) : super(OrionoidAuthState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _expirationTimer?.cancel();
    super.dispose();
  }

  Future<void> startAuth() async {
    try {
      state = state.copyWith(
        status: OrionoidAuthStatus.starting,
        errorMessage: null,
      );

      final authResponse = await _apiService.startAuth();
      
      if (authResponse.result.status == 'success') {
        final data = authResponse.data;
        if (data == null || data.code == null) {
          state = state.copyWith(
            status: OrionoidAuthStatus.failed,
            errorMessage: 'Authentication code not received',
          );
          return;
        }

        final expirationTime = data.expiration != null
            ? DateTime.fromMillisecondsSinceEpoch(data.expiration! * 1000)
            : DateTime.now().add(const Duration(minutes: 5));
        
        state = state.copyWith(
          status: OrionoidAuthStatus.waiting,
          authResponse: authResponse,
          expirationTime: expirationTime,
        );
        
        _startPolling(data.code!);
        _startExpirationTimer(expirationTime);
      } else {
        state = state.copyWith(
          status: OrionoidAuthStatus.failed,
          errorMessage: authResponse.result.message,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error starting Orionoid authentication', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: OrionoidAuthStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  void _startPolling(String code) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: state.pollingInterval),
      (_) => _checkAuthStatus(code),
    );
  }

  Future<void> _checkAuthStatus(String code) async {
    try {
      final authResponse = await _apiService.checkAuthStatus(code);
      
      if (authResponse.result.status == 'success') {
        if (authResponse.result.type == 'userauthapprove') {
          _pollingTimer?.cancel();
          _expirationTimer?.cancel();
          
          if (authResponse.data?.token != null) {
            await _apiService.setAuthToken(authResponse.data!.token!);
            logger.i('Orionoid authentication token saved');
          }
          
          state = state.copyWith(
            status: OrionoidAuthStatus.approved,
            authResponse: authResponse,
          );
        } else if (authResponse.result.type == 'userauthpending') {
          return;
        } else if (authResponse.result.type == 'userauthreject') {
          _pollingTimer?.cancel();
          _expirationTimer?.cancel();
          
          state = state.copyWith(
            status: OrionoidAuthStatus.failed,
            errorMessage: authResponse.result.message,
          );
        }
      } else if (authResponse.result.status == 'error') {
        _pollingTimer?.cancel();
        _expirationTimer?.cancel();
        
        state = state.copyWith(
          status: OrionoidAuthStatus.failed,
          errorMessage: authResponse.result.message,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error checking authentication status', error: e, stackTrace: stackTrace);
    }
  }

  void _startExpirationTimer(DateTime expirationTime) {
    _expirationTimer?.cancel();
    final now = DateTime.now();
    final duration = expirationTime.difference(now);
    
    if (duration.isNegative) {
      _expirationTimer?.cancel();
      state = state.copyWith(
        status: OrionoidAuthStatus.failed,
        errorMessage: 'Authentication expired',
      );
      return;
    }
    
    _expirationTimer = Timer(duration, () {
      _pollingTimer?.cancel();
      state = state.copyWith(
        status: OrionoidAuthStatus.failed,
        errorMessage: 'Authentication expired',
      );
    });
  }

  void reset() {
    _pollingTimer?.cancel();
    _expirationTimer?.cancel();
    state = OrionoidAuthState();
  }
}

final orionoidAuthProvider = StateNotifierProvider<OrionoidAuthNotifier, OrionoidAuthState>((ref) {
  final apiService = ref.watch(orionoidApiServiceProvider);
  return OrionoidAuthNotifier(apiService);
}); 