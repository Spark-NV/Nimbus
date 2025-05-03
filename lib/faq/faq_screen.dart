import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ & Information'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
        child: Column(
          children: [
            _ExpansionSection(
              title: 'Torrent/Magnet Selection Tips',
              children: [
                _InteractiveTorrentName(),
                _InfoItem(
                  title: '\nSeeders',
                  description: 'Always look for torrents with a high number of seeders. More seeders mean:\n'
                      '• Faster download speeds\n'
                      '• Better reliability\n'
                      '• Higher chance of complete download\n'
                      'Aim for torrents with at least 5-10 seeders for best results.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Language',
                  description: 'Check the language tags in the torrent name. Common indicators:\n'
                      '• ENG: English\n'
                      '• MULTi: Multiple languages\n'
                      '• SUB: Subtitles included\n'
                      '• DUB: Dubbed audio\n\n'
                      'Look for terms like "ENG", "English", or your preferred language in the filename.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Quality',
                  description: 'Quality indicators to look for:\n'
                      '• Resolution: 720p, 1080p, 4K, 8K\n'
                      '• Source: BluRay, WEB-DL, HDTV\n'
                      '• Codec: x264, x265 (HEVC)\n'
                      '• Audio: DTS, AC3, AAC\n\n'
                      'Higher quality files are larger but provide better viewing experience.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'File Size',
                  description: 'File size considerations:\n'
                      '• Movies: 1.5GB-15GB (1080p)\n'
                      '• TV Shows: 300MB-2GB per episode\n'
                      '• 4K Content: 20GB-100GB\n\n'
                      'Larger files generally indicate better quality, but consider:\n'
                      '• Download time\n'
                      '• Internet bandwidth - If you have a slow connection, a larger file will buffer/wont be watchable',
                  showDivider: false,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _ExpansionSection(
              title: 'Premiumize',
              children: [
                _InfoItem(
                  title: 'What is Premiumize?',
                  description: 'Premiumize is a premium cloud service that offers:\n'
                      '• Torrent downloading and streaming\n'
                      '• VPN service\n'
                      '• Usenet access\n'
                      '• Cloud storage\n'
                      '• CDN for faster downloads\n\n'
                      'It acts as a middleman, downloading torrents to their servers so you can stream or download them directly.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Is Premiumize Safe?',
                  description: 'Yes, Premiumize is a legitimate service that:\n'
                      '• Has been operating since 2013\n'
                      '• Uses secure HTTPS connections\n'
                      '• Offers VPN protection\n'
                      '• Has servers in multiple countries\n'
                      '• Provides encrypted storage\n\n'
                      'Your downloads are private and secure on their servers.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Pricing & Plans',
                  description: 'Premiumize offers several subscription options:\n'
                      '• Monthly: \$11.99/month\n'
                      '• 3 Months: \$29.99 (\$10/month)\n'
                      '• 12 Months: \$79.99 (\$6.57/month)\n\n'
                      'All plans include:\n'
                      '• 1TB storage\n'
                      '• Unlimited traffic\n'
                      '• 1000 points per day\n'
                      '• VPN access\n'
                      '• Usenet access',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Website',
                  description: 'Visit Premiumizes website',
                  isLink: true,
                  onTap: () => _launchUrl('https://www.premiumize.me'),
                  showDivider: false,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _ExpansionSection(
              title: 'Orionoid',
              children: [
                _InfoItem(
                  title: 'What is Orionoid?',
                  description: 'Orionoid is a service that provides:\n'
                      '• API access to multiple torrent sites\n'
                      '• Metadata for movies and TV shows\n'
                      '• Advanced search capabilities\n'
                      '• Quality filtering\n'
                      '• Real-time availability checking\n\n'
                      'It helps in finding and verifying torrents more efficiently.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Pricing & Plans',
                  description: 'Orionoid offers different tiers:\n'
                      '• Novice: \$0.50/month (\$6.00 total)\n'
                      '  - 1000 daily links\n'
                      '  - 5000 daily hashes\n'
                      '  - Full API access\n\n'
                      '• Beginner: \$1.00/month (\$12.00 total)\n'
                      '  - 5000 daily links\n'
                      '  - 25000 daily hashes\n'
                      '  - Full API access\n\n'
                      '• Expert: \$3.00/month (\$36.00 total)\n'
                      '  - 50000 daily links\n'
                      '  - 100000 daily hashes\n'
                      '  - Full API access\n\n'
                      '• Lifetime: \$199.00 (one-time payment)\n'
                      '  - Unlimited links and hashes\n'
                      '  - Full API access\n\n'
                      'The Beginner plan is usually sufficient for most users.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Is it Worth It?',
                  description: 'Orionoid is valuable because it:\n'
                      '• Saves time searching multiple sites\n'
                      '• Provides reliable metadata\n'
                      '• Filters out fake torrents\n'
                      '• Shows real-time availability\n'
                      '• Integrates well with other services\n\n'
                      'For regular users, the Beginner plan offers good value. And is totaly worth trying out assuming your client your using to stream with supports it.\nIf your client does not support orionoid do not pay for this as it wouldnt be worth it.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Website',
                  description: 'Visit Orionoids website',
                  isLink: true,
                  onTap: () => _launchUrl('https://orionoid.com'),
                  showDivider: false,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _ExpansionSection(
              title: 'Prowlarr',
              children: [
                _InfoItem(
                  title: 'What is Prowlarr?',
                  description: 'Prowlarr is a open source indexer manager/proxy that:\n'
                      '• Manages multiple indexers in one place\n'
                      '• Integrates with other *arr apps (Sonarr, Radarr, etc.)\n'
                      '• Supports multiple indexer types (Torznab, Newznab, etc.)\n'
                      '• Provides a unified search interface\n'
                      '• Automatically syncs with other *arr applications\n\n'
                      'It acts as a central hub for managing all your indexers.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Key Features',
                  description: 'Prowlarr offers several powerful features:\n'
                      '• Single interface for all indexers\n'
                      '• Automatic indexer synchronization\n'
                      '• Support for multiple indexer types\n'
                      '• API key management\n'
                      '• Indexer health monitoring\n'
                      '• Search history and statistics\n'
                      '• RSS feed management\n\n'
                      'It simplifies the process of managing multiple indexers.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Self-Hosting',
                  description: 'Prowlarr is designed to be self-hosted and requires:\n'
                      '• A server or computer to run on\n'
                      '• Docker or direct installation\n'
                      '• Port 9696 by default\n'
                      '• Basic system requirements:\n'
                      '  - 1GB RAM minimum\n'
                      '  - 100MB storage\n'
                      '  - Modern CPU\n\n'
                      'Installation options:\n'
                      '• Docker (recommended)\n'
                      '• Windows Service\n'
                      '• Linux Service\n'
                      '• Manual installation\n\n'
                      'Prowlarr runs as a web service and can be accessed through your browser once installed.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Integration with Nimbus',
                  description: 'Future integration plans include:\n'
                      '• Direct API integration\n'
                      '• Unified search results\n'
                      '• Automatic indexer configuration\n'
                      '• Health status monitoring\n'
                      '• Search history tracking\n\n'
                      'This will allow Nimbus to leverage Prowlarr\'s indexer management to find movies/tvshow links to send to premiumize.',
                  showDivider: true,
                ),
                _InfoItem(
                  title: 'Website',
                  description: 'Visit Prowlarrs github page',
                  isLink: true,
                  onTap: () => _launchUrl('https://github.com/Prowlarr/Prowlarr'),
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpansionSection extends StatefulWidget {
  const _ExpansionSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  State<_ExpansionSection> createState() => _ExpansionSectionState();
}

class _ExpansionSectionState extends State<_ExpansionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.white,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.title,
    required this.description,
    this.isLink = false,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String description;
  final bool isLink;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 12.h),
        MouseRegion(
          cursor: isLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: isLink ? onTap : null,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isLink ? Colors.blue : Colors.white.withOpacity(0.8),
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
            ),
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: 24.h),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
          ),
          SizedBox(height: 24.h),
        ],
      ],
    );
  }
}

class _InteractiveTorrentName extends StatefulWidget {
  const _InteractiveTorrentName();

  @override
  State<_InteractiveTorrentName> createState() => _InteractiveTorrentNameState();
}

class _InteractiveTorrentNameState extends State<_InteractiveTorrentName> {
  String? _selectedPart;
  final Map<String, Map<String, dynamic>> _partDescriptions = {
    'Movie.Name': {
      'description': 'The title of the movie or TV show',
      'details': 'This is the main title of the content. For TV shows, it might include the show name and episode information.',
    },
    '2023': {
      'description': 'The release year of the content',
      'details': 'Indicates when the content was released. For TV shows, this might be the year the episode aired.',
    },
    '1080p': {
      'description': 'The resolution of the video',
      'details': 'Common resolutions:\n'
          '• 720p: HD (1280x720)\n'
          '• 1080p: Full HD (1920x1080)\n'
          '• 2160p: 4K (3840x2160)\n'
          '• 4320p: 8K (7680x4320)\n\n'
          'Higher resolution means better quality but larger file size.',
    },
    'BluRay': {
      'description': 'The source quality',
      'details': 'Common sources:\n'
          '• BluRay: Highest quality, from physical discs\n'
          '• WEB-DL: Direct download from streaming services\n'
          '• HDTV: Recorded from TV broadcast\n'
          '• WEBRip: Ripped from streaming services\n'
          '• DVD: Standard definition from DVD\n\n'
          'BluRay and WEB-DL are generally preferred for best quality.',
    },
    'ENG': {
      'description': 'English audio track included',
      'details': 'Language indicators:\n'
          '• ENG: English\n'
          '• MULTi: Multiple languages\n'
          '• DUB: Dubbed audio\n'
          '• AC3: Dolby Digital audio\n'
          '• DTS: Digital Theater Systems audio\n\n'
          'Look for your preferred language in the filename.',
    },
    'ITA': {
      'description': 'Italian audio track included',
      'details': 'Multiple language tracks are common in torrents. Common language codes:\n'
          '• ENG: English\n'
          '• ITA: Italian\n'
          '• FRE: French\n'
          '• GER: German\n'
          '• SPA: Spanish\n'
          '• JPN: Japanese\n\n'
          'MULTi indicates multiple language tracks are available.',
    },
    'SUB': {
      'description': 'Subtitles are included',
      'details': 'Subtitle information:\n'
          '• SUB: Subtitles included\n'
          '• SRT: SubRip subtitle format\n'
          '• ASS/SSA: Advanced SubStation Alpha format\n'
          '• PGS: BluRay subtitle format\n\n'
          'Common subtitle languages:\n'
          '• EN: English\n'
          '• ES: Spanish\n'
          '• FR: French\n'
          '• DE: German\n'
          '• IT: Italian\n\n'
          'Some releases include multiple subtitle tracks.',
    },
    'x264': {
      'description': 'The video codec used for compression',
      'details': 'Common video codecs:\n'
          '• x264: H.264/AVC compression\n'
          '• x265: H.265/HEVC compression (better compression)\n'
          '• XviD: Older MPEG-4 codec\n'
          '• DivX: Proprietary MPEG-4 codec\n\n'
          'x265 offers better compression but requires more processing power.',
    },
    'GROUP': {
      'description': 'The release group that created this version',
      'details': 'Release groups are teams that create and distribute content. They often have specific:\n'
          '• Quality standards\n'
          '• Encoding preferences\n'
          '• Naming conventions\n\n'
          'Some well-known groups are known for their high-quality releases.',
    },
    '.avi': {
      'description': 'The file extension/container format',
      'details': 'Common container formats:\n'
          '• MKV: Matroska (most flexible)\n'
          '• MP4: Common for streaming\n'
          '• AVI: Older format\n'
          '• MOV: QuickTime format\n\n'
          'MKV is preferred as it supports multiple audio tracks and subtitles.',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Understanding Torrent Names - click parts of this example to learn more',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    _buildInteractiveSpan('Movie.Name'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('2023'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('1080p'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('BluRay'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('ENG'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('ITA'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('SUB'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('x264'),
                    TextSpan(text: '-'),
                    _buildInteractiveSpan('GROUP'),
                    TextSpan(text: '.'),
                    _buildInteractiveSpan('.avi'),
                  ],
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
              ),
              if (_selectedPart != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _partDescriptions[_selectedPart]!['description'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _partDescriptions[_selectedPart]!['details'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  TextSpan _buildInteractiveSpan(String part) {
    final isSelected = _selectedPart == part;
    return TextSpan(
      text: part,
      style: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.blue,
        decoration: isSelected ? TextDecoration.underline : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          setState(() {
            _selectedPart = isSelected ? null : part;
          });
        },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.tag, this.description);

  final String tag;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          tag,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ),
    );
  }
} 