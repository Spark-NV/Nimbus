import 'package:flutter/material.dart';

class TorrentSite {
  final String name;
  final String url;
  final IconData icon;
  final String description;

  const TorrentSite({
    required this.name,
    required this.url,
    required this.icon,
    required this.description,
  });
}

final List<TorrentSite> recommendedTorrentSites = [
  const TorrentSite(
    name: '1337x',
    url: 'https://1337x.to',
    icon: Icons.search,
    description: 'Massive torrent index with excellent organization, featuring movies, TV shows, with active community verification',
  ),
  const TorrentSite(
    name: 'Zooqle',
    url: 'https://zooqle.io/',
    icon: Icons.search,
    description: 'Clean interface with verified torrents, specializing in HD movies and complete TV series collections',
  ),
  const TorrentSite(
    name: 'The Pirate Bay',
    url: 'https://thepiratebay.org',
    icon: Icons.search,
    description: 'Legendary torrent pioneer with resilient infrastructure and vast content across all categories',
  ),
  const TorrentSite(
    name: 'EZTV',
    url: 'https://eztvx.to/',
    icon: Icons.search,
    description: 'Premium source for only TV shows with fast episode uploads and reliable seeders',
  ),
  const TorrentSite(
    name: 'YTS',
    url: 'https://yts.mx',
    icon: Icons.search,
    description: 'Specializes in high-compression, quality movie torrents with small file sizes and consistent availability',
  ),
  const TorrentSite(
    name: 'Torrentz2',
    url: 'https://torrentz2.nz',
    icon: Icons.search,
    description: 'Privacy-focused meta-search engine that aggregates results from multiple torrent sites',
  ),
  const TorrentSite(
    name: 'Nyaa',
    url: 'https://nyaa.land/',
    icon: Icons.search,
    description: 'The go-to destination for anime content, including raw, dubbed, and subbed releases',
  ),
  const TorrentSite(
    name: 'EXT',
    url: 'https://ext.to/',
    icon: Icons.search,
    description: 'Rapid-release platform for new movies and TV episodes with quality filtering options',
  ),
  const TorrentSite(
    name: 'LimeTorrents',
    url: 'https://limetorrent.net/',
    icon: Icons.search,
    description: 'Comprehensive aggregator with detailed torrent information and health indicators',
  ),
  const TorrentSite(
    name: 'ABC Torrents',
    url: 'https://abctorrents.xyz/',
    icon: Icons.search,
    description: 'Niche content specialist with strong collections in documentaries and educational material',
  ),
  const TorrentSite(
    name: 'Bitsearch',
    url: 'https://bitsearch.to/',
    icon: Icons.search,
    description: 'Modern interface with advanced search filters and torrent analytics',
  ),
  const TorrentSite(
    name: 'BT4G',
    url: 'https://bt4gprx.com/',
    icon: Icons.search,
    description: 'High-performance search engine for torrents with magnet link focus',
  ),
  const TorrentSite(
    name: 'TorrentDownloads',
    url: 'https://torrentdownloads.pro/',
    icon: Icons.search,
    description: 'Long-standing repository',
  ),
  const TorrentSite(
    name: 'BTDig',
    url: 'https://btdig.com/',
    icon: Icons.search,
    description: 'Unique DHT-based search that finds torrents other indexes might miss',
  ),
  const TorrentSite(
    name: 'Filemood',
    url: 'https://filemood.com/',
    icon: Icons.search,
    description: 'Curated selection of high-quality movie encodes with consistent availability',
  ),
  const TorrentSite(
    name: 'TorrentDownload',
    url: 'https://torrentdownload.info/',
    icon: Icons.search,
    description: 'Straightforward interface with verified torrents and daily content updates',
  ),
]; 