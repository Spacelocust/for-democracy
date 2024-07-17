enum NotificationType {
  groupJoined(
    'group_joined',
  ),

  groupUpdated(
    'group_updated',
  ),

  groupLeft(
    'group_left',
  ),

  missionJoined(
    'mission_joined',
  ),

  missionLeft(
    'mission_left',
  ),

  missionUpdated(
    'mission_updated',
  ),

  missionCreated(
    'mission_created',
  );

  final String type;

  const NotificationType(this.type);
}
