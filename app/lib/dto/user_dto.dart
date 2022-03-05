class UserDto {
  int id;
  String first_name;
  String last_name;
  String email;
  String created_at;

  UserDto(
      this.id, this.first_name, this.last_name, this.email, this.created_at);

  factory UserDto.fromJson(json) {
    return UserDto(
      json['id'] as int,
      json['first_name'] as String,
      json['last_name'] as String,
      json['email'] as String,
      json['created_at'] as String,
    );
  }

  @override
  String toString() {
    return '{ ${id}, ${first_name}, ${last_name}, ${email}, , ${created_at} }';
  }
}
