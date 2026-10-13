import 'package:flutter_test/flutter_test.dart';
import 'package:room_search/domain/entities/rental_request_entity.dart';
import 'package:room_search/presentation/providers/landlord_provider.dart';

void main() {
  group('LandlordProvider Rental Request Rejection & Resubmit Test', () {
    test('Rejected rental request should allow student to submit new request', () async {
      final provider = LandlordProvider();

      final request = RentalRequestEntity(
        maYeuCau: 'YC-20260808-001',
        maSV: 'STUDENT_1',
        tenSV: 'Sinh viên 1',
        maChuTro: 'LANDLORD_1',
        maPhong: 'P-CG-20260808-001',
        ngayMuonVaoO: DateTime.now(),
        thoiHanThue: 6,
        soNguoiO: 1,
        ghiChu: '',
        trangThai: 'CHO_XU_LY',
        ngayTao: DateTime.now(),
      );

      await provider.addRentalRequest(request);

      expect(
        provider.hasActiveRequestForRoom(
          studentId: 'STUDENT_1',
          studentName: 'Sinh viên 1',
          roomId: 'P-CG-20260808-001',
        ),
        isTrue,
      );

      // Landlord rejects the request
      final ok = await provider.rejectRentalRequest('YC-20260808-001', 'Phòng đã có người ở');
      expect(ok, isTrue);

      // Verify request is no longer active so student can re-submit
      expect(
        provider.hasActiveRequestForRoom(
          studentId: 'STUDENT_1',
          studentName: 'Sinh viên 1',
          roomId: 'P-CG-20260808-001',
        ),
        isFalse,
      );
    });
  });
}
