import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Nimbus',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
          SizedBox(height: 40.h),
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            path: '/',
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Search',
            path: '/search',
          ),
          _NavItem(
            icon: Icons.cloud_outlined,
            label: 'Premiumize',
            path: '/premiumize',
          ),
          _NavItem(
            icon: Icons.add_link,
            label: 'Manual',
            path: '/manual',
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            path: '/settings',
          ),
          _NavItem(
            icon: Icons.help_outline,
            label: 'FAQ',
            path: '/faq',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    isSelected = currentPath == widget.path;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: InkWell(
          onTap: () => context.go(widget.path),
          borderRadius: BorderRadius.circular(12.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : isHovered 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 24.w,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
                if (isHovered && !isSelected)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.0),
                            Colors.blue.withOpacity(0.1),
                            Colors.blue.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Container(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white.withOpacity(0.1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 