part of actions;

@freezed
class CreateUser with _$CreateUser {
  const factory CreateUser({
    required String email,
    required String password,
    required String displayName,
    required ActionResponse response,
    required String role,
    @Default('') String lat,
    @Default('') String lng,
  }) = CreateUserStart;

  const factory CreateUser.successful() = CreateUserSuccessful;

  const factory CreateUser.error(Object error, StackTrace stackTrace) = CreateUserError;
}