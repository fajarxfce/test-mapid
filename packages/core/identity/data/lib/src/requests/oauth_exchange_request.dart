import 'package:json_annotation/json_annotation.dart';

part 'oauth_exchange_request.g.dart';

@JsonSerializable(createFactory: false, fieldRename: FieldRename.snake)
final class OAuthExchangeRequest {
  const OAuthExchangeRequest({
    required this.code,
    required this.codeVerifier,
    required this.redirectUri,
  });

  final String code;
  final String codeVerifier;
  final String redirectUri;

  Map<String, dynamic> toJson() => _$OAuthExchangeRequestToJson(this);
}
