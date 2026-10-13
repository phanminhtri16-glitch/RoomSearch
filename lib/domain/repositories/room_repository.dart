import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getApprovedRooms({String? quanHuyen, String? searchKeyword});

  Future<List<RoomEntity>> getRoomsByLandlord(String landlordId);

  Future<List<RoomEntity>> getPendingApprovalRooms();

  Future<RoomEntity?> getRoomById(String roomId);

  Future<RoomEntity> createRoomListing(RoomEntity room);

  Future<RoomEntity> updateRoomListing(RoomEntity room);

  Future<void> updateRoomApprovalStatus(String roomId, String status, {String? reason});

  Future<void> toggleRoomVisibility(String roomId, bool isHienThi);

  Future<void> relistRoom(String roomId);

  Future<void> incrementRoomViewCount(String roomId);

  Future<void> deleteRoomListing(String roomId);
}
