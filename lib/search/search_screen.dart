import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'search_provider.dart';
import '../omdb/omdb_search_result.dart';
import 'combined_streams_provider.dart';
import 'combined_streams_screen.dart';
import '../indexers/torrentio_response.dart';
import '../indexers/orionoid_response.dart';
import 'package:logger/logger.dart';
import 'tv_show_selection_dialog.dart';

final logger = Logger();

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);

    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 24.h),
          const _SearchForm(),
          SizedBox(height: 32.h),
          Expanded(
            child: searchState.when(
              data: (results) => _SearchResults(results: results),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchForm extends ConsumerStatefulWidget {
  const _SearchForm();

  @override
  ConsumerState<_SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends ConsumerState<_SearchForm> {
  final _queryController = TextEditingController();
  final _yearController = TextEditingController();
  MediaType? _selectedType;

  @override
  void dispose() {
    _queryController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleSearch() async {
    if (_queryController.text.isEmpty) return;

    ref.read(searchStateProvider.notifier).search(
          query: _queryController.text,
          year: _yearController.text,
          type: _selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    hintText: 'Search for movies and TV shows...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 150.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _yearController,
                decoration: InputDecoration(
                  hintText: 'Year',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _handleSearch(),
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 240.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MediaType>(
                  value: _selectedType,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Type',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: MediaType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          type == MediaType.movie ? 'Movie' : 'TV Show',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'Search',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final List<OmdbSearchItem> results;

  const _SearchResults({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.w,
              color: Colors.white.withOpacity(0.2),
            ),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final columns = (screenWidth / 300).floor();
    final aspectRatio = 0.7;
    final imageHeight = 300.h;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _HoverableSearchItem(
          item: item,
          imageHeight: imageHeight,
          onTap: () async {
            try {
              final enabledProviders = ref.read(enabledMovieStreamProvidersProvider);
              if (enabledProviders.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No stream providers are enabled. Please enable at least one provider in settings.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              final allStreams = <dynamic>[];
              for (final provider in enabledProviders) {
                try {
                  if (item.Type == 'series') {
                    final result = await showDialog<(int, int)?>(
                      context: context,
                      builder: (context) => const TvShowSelectionDialog(),
                    );

                    if (result == null) return;

                    final (season, episode) = result;
                    final episodeProviders = ref.read(enabledEpisodeStreamProvidersProvider);
                    for (final episodeProvider in episodeProviders) {
                      try {
                        final streams = await episodeProvider((
                          imdbId: item.imdbId,
                          seasonNumber: season,
                          episodeNumber: episode,
                        ));
                        allStreams.addAll(streams.streams);
                      } catch (e) {
                        logger.w('Error fetching episode streams from provider', error: e);
                      }
                    }
                  } else {
                    final streams = await provider(item.imdbId);
                    if (streams is TorrentioResponse) {
                      allStreams.addAll(streams.streams);
                    } else if (streams is OrionoidResponse) {
                      allStreams.addAll(streams.streams);
                    }
                  }
                } catch (e) {
                  logger.w('Error fetching streams from provider', error: e);
                }
              }

              if (allStreams.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No streams found for this title.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CombinedStreamsScreen(
                      streams: allStreams,
                      title: item.Title,
                    ),
                  ),
                );
              }
            } catch (e) {
              logger.e('Error fetching streams', error: e);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading streams: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _HoverableSearchItem extends StatefulWidget {
  final OmdbSearchItem item;
  final double imageHeight;
  final VoidCallback onTap;

  const _HoverableSearchItem({
    required this.item,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  State<_HoverableSearchItem> createState() => _HoverableSearchItemState();
}

class _HoverableSearchItemState extends State<_HoverableSearchItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.Poster != 'N/A')
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Image.network(
                      widget.item.Poster,
                      height: widget.imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: widget.imageHeight,
                          width: double.infinity,
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48.w,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: widget.imageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48.w,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.Title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${widget.item.Year} • ${widget.item.Type == 'movie' ? 'Movie' : 'TV Show'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'IMDB: ${widget.item.imdbId}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 