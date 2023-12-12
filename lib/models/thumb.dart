import 'package:freezed_annotation/freezed_annotation.dart';

part 'thumb.freezed.dart';

part 'thumb.g.dart';

@unfreezed
class Photo with _$Photo {
  factory Photo({
    required int albumId,
    required final int id,
    required String title,
    required String url,
    required String thumbnailUrl,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
