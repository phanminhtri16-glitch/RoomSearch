import '../../domain/entities/system_param_entity.dart';

class SystemParamModel extends SystemParamEntity {
  SystemParamModel({
    super.minUserAge = 18,
    super.otpValidityDurationSeconds = 300,
    super.otpMaxAttempts = 3,
    super.otpLockoutDurationSeconds = 900,
    super.minListingImages = 3,
    super.minListingPrice = 500000.0,
    super.adminApprovalDeadlineHours = 24,
    super.maxRejectionResubmissions = 3,
    super.maxPendingRequestsPerStudent = 5,
    super.landlordResponseDeadlineHours = 48,
    super.minStayDaysForReview = 7,
    super.minReviewLength = 20,
    super.maxFavoriteRoomsPerStudent = 50,
    super.depositConfirmationSeconds = 60,
  });

  factory SystemParamModel.fromMap(Map<String, dynamic> map) {
    return SystemParamModel(
      minUserAge: map['MinUserAge'] ?? 18,
      otpValidityDurationSeconds: map['OtpValidityDurationSeconds'] ?? 300,
      otpMaxAttempts: map['OtpMaxAttempts'] ?? 3,
      otpLockoutDurationSeconds: map['OtpLockoutDurationSeconds'] ?? 900,
      minListingImages: map['MinListingImages'] ?? 3,
      minListingPrice: (map['MinListingPrice'] ?? 500000.0).toDouble(),
      adminApprovalDeadlineHours: map['AdminApprovalDeadlineHours'] ?? 24,
      maxRejectionResubmissions: map['MaxRejectionResubmissions'] ?? 3,
      maxPendingRequestsPerStudent: map['MaxPendingRequestsPerStudent'] ?? 5,
      landlordResponseDeadlineHours: map['LandlordResponseDeadlineHours'] ?? 48,
      minStayDaysForReview: map['MinStayDaysForReview'] ?? 7,
      minReviewLength: map['MinReviewLength'] ?? 20,
      maxFavoriteRoomsPerStudent: map['MaxFavoriteRoomsPerStudent'] ?? 50,
      depositConfirmationSeconds: map['DepositConfirmationSeconds'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MinUserAge': minUserAge,
      'OtpValidityDurationSeconds': otpValidityDurationSeconds,
      'OtpMaxAttempts': otpMaxAttempts,
      'OtpLockoutDurationSeconds': otpLockoutDurationSeconds,
      'MinListingImages': minListingImages,
      'MinListingPrice': minListingPrice,
      'AdminApprovalDeadlineHours': adminApprovalDeadlineHours,
      'MaxRejectionResubmissions': maxRejectionResubmissions,
      'MaxPendingRequestsPerStudent': maxPendingRequestsPerStudent,
      'LandlordResponseDeadlineHours': landlordResponseDeadlineHours,
      'MinStayDaysForReview': minStayDaysForReview,
      'MinReviewLength': minReviewLength,
      'MaxFavoriteRoomsPerStudent': maxFavoriteRoomsPerStudent,
      'DepositConfirmationSeconds': depositConfirmationSeconds,
    };
  }
}
