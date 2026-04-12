import 'package:equatable/equatable.dart';

/// Floor price data point for an NFT collection (S492).
class NftFloorPriceEntry extends Equatable {
  const NftFloorPriceEntry({
    required this.collectionSlug,
    required this.collectionName,
    required this.floorPriceEth,
    required this.floorPriceUsd,
    required this.volume24hEth,
    required this.holderCount,
  });

  final String collectionSlug;
  final String collectionName;
  final double floorPriceEth;
  final double floorPriceUsd;
  final double volume24hEth;

  /// Number of unique wallet holders.
  final int holderCount;

  bool get isBlueChip => floorPriceEth >= 1.0;
  bool get isHighVolume => volume24hEth >= 100.0;
  bool get hasLargeHolder => holderCount >= 5000;

  @override
  List<Object?> get props => [
    collectionSlug,
    collectionName,
    floorPriceEth,
    floorPriceUsd,
    volume24hEth,
    holderCount,
  ];
}
