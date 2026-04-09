import 'package:equatable/equatable.dart';

/// Type of content block within a digest.
enum DigestBlockType {
  header,
  text,
  alertSummary,
  chartRef,
  priceTable,
  footer,
}

/// A typed content block used to compose email or in-app digests.
class DigestContentBlock extends Equatable {
  const DigestContentBlock({
    required this.blockType,
    required this.heading,
    this.body,
    this.tickerRef,
    this.numericValue,
    this.sortOrder = 0,
  });

  final DigestBlockType blockType;
  final String heading;
  final String? body;
  final String? tickerRef;
  final double? numericValue;

  /// Lower values are rendered first.
  final int sortOrder;

  bool get hasTickerRef => tickerRef != null;
  bool get hasNumericValue => numericValue != null;

  @override
  List<Object?> get props => [
    blockType,
    heading,
    body,
    tickerRef,
    numericValue,
    sortOrder,
  ];
}

/// An ordered collection of [DigestContentBlock]s forming one digest.
class DigestTemplate extends Equatable {
  const DigestTemplate({
    required this.id,
    required this.name,
    required this.blocks,
  });

  final String id;
  final String name;
  final List<DigestContentBlock> blocks;

  /// Blocks sorted ascending by [DigestContentBlock.sortOrder].
  List<DigestContentBlock> get sorted {
    final copy = [...blocks]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  bool get isEmpty => blocks.isEmpty;

  @override
  List<Object?> get props => [id, name, blocks];
}
