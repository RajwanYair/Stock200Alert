import 'package:equatable/equatable.dart';

/// Entity a [UserAnnotation] is attached to.
enum AnnotationTarget { candle, ticker, alert, watchlist }

/// Display colour for a [UserAnnotation].
enum AnnotationColor { red, orange, yellow, green, blue, purple, gray }

/// A user-authored note or tag attached to any domain entity.
class UserAnnotation extends Equatable {
  const UserAnnotation({
    required this.id,
    required this.target,
    required this.targetId,
    required this.text,
    required this.createdAt,
    this.color = AnnotationColor.yellow,
    this.tags = const [],
    this.isVisible = true,
    this.updatedAt,
  }) : assert(text.length > 0, 'text must not be empty');

  final String id;
  final AnnotationTarget target;
  final String targetId;
  final String text;
  final DateTime createdAt;
  final AnnotationColor color;
  final List<String> tags;
  final bool isVisible;
  final DateTime? updatedAt;

  bool get hasBeenEdited => updatedAt != null;
  bool get hasTags => tags.isNotEmpty;

  UserAnnotation withText(String newText, DateTime editedAt) => UserAnnotation(
    id: id,
    target: target,
    targetId: targetId,
    text: newText,
    createdAt: createdAt,
    color: color,
    tags: tags,
    isVisible: isVisible,
    updatedAt: editedAt,
  );

  UserAnnotation hide() => UserAnnotation(
    id: id,
    target: target,
    targetId: targetId,
    text: text,
    createdAt: createdAt,
    color: color,
    tags: tags,
    isVisible: false,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    target,
    targetId,
    text,
    createdAt,
    color,
    tags,
    isVisible,
    updatedAt,
  ];
}
