class SystemParamEntity {
  final int minUserAge;
  final int otpValidityDurationSeconds;
  final int otpMaxAttempts;
  final int otpLockoutDurationSeconds;
  final int minListingImages;
  final double minListingPrice;
  final int adminApprovalDeadlineHours;
  final int maxRejectionResubmissions;
  final int maxPendingRequestsPerStudent;
  final int landlordResponseDeadlineHours;
  final int minStayDaysForReview;
  final int minReviewLength;
  final int maxFavoriteRoomsPerStudent;
  final int depositConfirmationSeconds;

  SystemParamEntity({
    this.minUserAge = 18,
    this.otpValidityDurationSeconds = 300,
    this.otpMaxAttempts = 3,
    this.otpLockoutDurationSeconds = 900,
    this.minListingImages = 3,
    this.minListingPrice = 500000.0,
    this.adminApprovalDeadlineHours = 24,
    this.maxRejectionResubmissions = 3,
    this.maxPendingRequestsPerStudent = 5,
    this.landlordResponseDeadlineHours = 48,
    this.minStayDaysForReview = 7,
    this.minReviewLength = 20,
    this.maxFavoriteRoomsPerStudent = 50,
    this.depositConfirmationSeconds = 60,
  });
}
