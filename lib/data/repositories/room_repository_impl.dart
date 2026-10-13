import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_datasource.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDatasource _remoteDatasource;

  RoomRepositoryImpl({RoomRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? RoomRemoteDatasource();

  @override
  Future<List<RoomEntity>> getApprovedRooms({String? quanHuyen, String? searchKeyword}) {
    return _remoteDatasource.getApprovedRooms(
      quanHuyen: quanHuyen,
      searchKeyword: searchKeyword,
    );
  }

  @override
  Future<List<RoomEntity>> getRoomsByLandlord(String landlordId) {
    return _remoteDatasource.getRoomsByLandlord(landlordId);
  }

  @override
  Future<List<RoomEntity>> getPendingApprovalRooms() {
    return _remoteDatasource.getPendingApprovalRooms();
  }

  @override
  Future<RoomEntity?> getRoomById(String roomId) {
    return _remoteDatasource.getRoomById(roomId);
  }

  @override
  Future<RoomEntity> createRoomListing(RoomEntity room) {
    return _remoteDatasource.createRoomListing(RoomModel.fromEntity(room));
  }

  @override
  Future<RoomEntity> updateRoomListing(RoomEntity room) {
    return _remoteDatasource.updateRoomListing(RoomModel.fromEntity(room));
  }

  @override
  Future<void> updateRoomApprovalStatus(String roomId, String status, {String? reason}) {
    return _remoteDatasource.updateRoomApprovalStatus(roomId, status, reason: reason);
  }

  @override
  Future<void> toggleRoomVisibility(String roomId, bool isHienThi) {
    return _remoteDatasource.toggleRoomVisibility(roomId, isHienThi);
  }

  @override
  Future<void> relistRoom(String roomId) {
    return _remoteDatasource.relistRoom(roomId);
  }

  @override
  Future<void> incrementRoomViewCount(String roomId) {
    return _remoteDatasource.incrementRoomViewCount(roomId);
  }

  @override
  Future<void> deleteRoomListing(String roomId) {
    return _remoteDatasource.deleteRoomListing(roomId);
  }
}
