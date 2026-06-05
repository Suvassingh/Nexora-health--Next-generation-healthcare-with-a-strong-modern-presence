// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Telemedical App';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get donthaveanaccout => 'Don\'t have an account ?';

  @override
  String get signup => 'Sign Up';

  @override
  String get bookAppointment => 'Book\nAppointment';

  @override
  String get doctor => 'Doctor';

  @override
  String get patient => 'Patient';

  @override
  String get homeScreen => 'Home Screen';

  @override
  String get name => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get address => 'Address';

  @override
  String get alreadyhaveanaccount => 'Already Have An Account ?';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get others => 'Other';

  @override
  String get confirmpassword => 'Confirm Password';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading';

  @override
  String get namaste => 'Namaste';

  @override
  String get howareyoufeelingtoday => 'How are you feeling today?';

  @override
  String get edit => 'Edit';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get cancelAppointmentTitle => 'Cancel Appointment?';

  @override
  String cancelAppointmentConfirm(String doctorName) {
    return 'Do you want to cancel the appointment with Dr. $doctorName?';
  }

  @override
  String get no => 'No';

  @override
  String get cancelConfirmBtn => 'Cancel it';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get book => 'Book';

  @override
  String get viewAll => 'View All';

  @override
  String get upcomingAppointment => 'Upcoming Appointment';

  @override
  String get noUpcomingAppointment => 'No upcoming appointments';

  @override
  String get bookNewAppointmentHint => 'Press the button below to book a new appointment';

  @override
  String get totalConsultations => 'Total';

  @override
  String get thisMonth => 'This Month';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get thisWeekAppointments => 'This Week';

  @override
  String get findDoctor => 'Find a Doctor';

  @override
  String get recentAppointments => 'Recent Appointments';

  @override
  String get noAppointmentsYet => 'No appointments yet';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get chat => 'Chat';

  @override
  String get emergencyContact => 'Emergency\nContact';

  @override
  String get numberLabel => 'Number:';

  @override
  String get confirmCall => 'Do you want to call this number?';

  @override
  String get callBtn => 'Call';

  @override
  String get numberCopied => 'Number Copied';

  @override
  String numberCopiedToClipboard(String number) {
    return '$number copied to clipboard';
  }

  @override
  String get save => 'Save';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get changePassword => 'Change Password';

  @override
  String get consultationType => 'Consultation Type';

  @override
  String get selectDoctor => 'Select Doctor';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get symptomsAndSummary => 'Symptoms & Summary';

  @override
  String get bookAppointmentBtn => 'Book Appointment';

  @override
  String get nextArrow => 'Next →';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get appointmentBooked => 'Appointment Booked!';

  @override
  String get ok => 'OK';

  @override
  String get howToConsult => 'How would you like to consult?';

  @override
  String get selectConsultationType => 'Select a consultation type';

  @override
  String get selectProvince => 'Select Province';

  @override
  String get selectProvinceFirst => 'Select Province first';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get selectDistrictFirst => 'Select District first';

  @override
  String get selectMunicipality => 'Municipality (optional)';

  @override
  String get selectProvinceAndDistrict => 'Select province and district';

  @override
  String get noDoctorsInArea => 'No doctors found in this area';

  @override
  String get all => 'All';

  @override
  String get healthInstitution => 'Health Institution';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get type => 'Type';

  @override
  String get symptomsOptional => 'Symptoms (optional)';

  @override
  String get symptomsHint => 'Write your symptoms here...';

  @override
  String get doctorLoadFailed => 'Failed to load doctors';

  @override
  String get slotAlreadyBooked => 'This slot is taken, please choose another.';

  @override
  String get bookingFailed => 'Booking failed';

  @override
  String get pleaseLoginFirst => 'Please login first.';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get today => 'Today';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get newBook => 'New Book';

  @override
  String get noAppointmentsToday => 'No appointments today';

  @override
  String get noPendingAppointments => 'No pending appointments';

  @override
  String get noCompletedAppointments => 'No completed appointments';

  @override
  String get noCancelledAppointments => 'No cancelled appointments';

  @override
  String get todaysAppointment => 'Today\'s Appointment';

  @override
  String get awaitingDoctorConfirmation => 'Awaiting doctor confirmation';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get appointmentCancelledSuccess => 'Appointment successfully cancelled.';

  @override
  String get cancelFailed => 'Could not cancel';

  @override
  String get actionIrreversible => 'This action cannot be undone.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get videoCameraPermission => 'Camera and microphone permission required for video call.';

  @override
  String get audioMicPermission => 'Microphone permission required for audio call.';

  @override
  String get doctorIdNotFound => 'Doctor ID not found. Please reload.';

  @override
  String get callFailed => 'Could not start call';

  @override
  String get physicalVisit => 'Physical Visit';

  @override
  String physicalVisitDetail(String doctorName, String healthpost) {
    return 'Physical consultation with Dr. $doctorName at $healthpost';
  }

  @override
  String get joinVideoCall => 'Join Video Call';

  @override
  String get joinAudioCall => 'Join Audio Call';

  @override
  String get startChat => 'Start Chat';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewLocation => 'View Location';

  @override
  String get videoConsultation => 'Video Consultation';

  @override
  String get phoneConsultation => 'Phone Consultation';

  @override
  String get messageConsultation => 'Message Consultation';

  @override
  String get reason => 'Reason';

  @override
  String get appointmentPendingConfirmation => 'This appointment is still awaiting doctor confirmation.';

  @override
  String get physical => 'Physical';

  @override
  String get dataLoadFailed => 'Failed to load data';

  @override
  String get connecting => 'Connecting…';

  @override
  String get connected => 'Connected';

  @override
  String get ringing => 'Ringing…';

  @override
  String get callError => 'Call Error';

  @override
  String get settingUpCall => 'Setting up call…';

  @override
  String get unmute => 'Unmute';

  @override
  String get mute => 'Mute';

  @override
  String get camOn => 'Cam On';

  @override
  String get camOff => 'Cam Off';

  @override
  String get speaker => 'Speaker';

  @override
  String get earpiece => 'Earpiece';

  @override
  String get flip => 'Flip';

  @override
  String get callHistory => 'Call History';

  @override
  String get noCallsYet => 'No calls yet';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthExcellent => 'Strong';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String get currentPasswordWrong => 'Current password is incorrect';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get passwordSecurityInfo => 'For security, please enter your current password first. The new password must be at least 8 characters.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get currentPasswordHint => 'Enter current password';

  @override
  String get currentPasswordRequired => 'Current password is required';

  @override
  String get newPassword => 'New Password';

  @override
  String get newPasswordHint => 'Enter new password';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get minEightChars => 'Must be at least 8 characters';

  @override
  String get passwordMustDiffer => 'New password must differ from current';

  @override
  String get repeatPasswordHint => 'Repeat new password';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordStrength => 'Password strength';

  @override
  String get passwordTipsTitle => 'For a secure password:';

  @override
  String get tipMinChars => 'Use at least 8 characters';

  @override
  String get tipMixCase => 'Mix uppercase and lowercase (A–Z, a–z)';

  @override
  String get tipIncludeNumbers => 'Include numbers (0–9)';

  @override
  String get tipSpecialChars => 'Add special characters (!@#\$%)';

  @override
  String get chatInitFailed => 'Failed to initialize chat';

  @override
  String get mediaUploadFailed => 'Failed to send media';

  @override
  String get typeAMessage => 'Type a message…';

  @override
  String get messages => 'Messages';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get bookChatAppointmentHint => 'Book a chat appointment to start messaging\nyour doctor.';

  @override
  String get doctorPrefix => 'Dr.';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get loggingIn => 'Logging in…';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get orSignupWith => 'or sign up with';

  @override
  String get google => 'Google';

  @override
  String get creatingAccount => 'Creating account…';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get ageRequired => 'Age is required';

  @override
  String get genderRequired => 'Gender is required';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get passwordMinSix => 'Password must be at least 6 characters';

  @override
  String get signUpFailed => 'Sign Up Failed';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String get accountSetupComplete => 'Account setup complete. Please login.';

  @override
  String get emailAlreadyRegistered => 'This email is already registered. Please login instead.';

  @override
  String get incompleteProfile => 'Incomplete Profile';

  @override
  String get completeProfileHint => 'Please complete your profile information.';

  @override
  String get googleSignInFailed => 'Google Sign-In Failed';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get available => 'Available';

  @override
  String get busy => 'Busy';

  @override
  String get sun => 'Sun';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get selectDateAndTime => 'Select Date & Time';

  @override
  String get selectTime => 'Select Time';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get selectDateFirst => 'Please select a date first';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No Show';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get tapToStartChatting => 'Tap to start chatting';

  @override
  String get newLabel => 'New';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get couldNotLoadData => 'Could not load data';

  @override
  String get fullName => 'Full Name';

  @override
  String get verified => 'Verified';

  @override
  String get ageAndDob => 'Age / Date of Birth';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get select => 'Select';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get add => 'Add';

  @override
  String get noRecords => 'No records found';

  @override
  String get addCondition => 'Add Condition';

  @override
  String get conditionHint => 'e.g. Hypertension';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language / भाषा';

  @override
  String get nepali => 'Nepali';

  @override
  String get lowDataMode => 'Low Data Mode';

  @override
  String get lowDataModeSubtitle => 'Low Data Mode';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get profileSaved => 'Profile saved ✓';

  @override
  String failedToSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get selectDateOfBirth => 'Select Date of Birth';

  @override
  String get appointmentCancelled => 'Appointment cancelled.';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get seeAll => 'See All';

  @override
  String get noDoctorsAvailable => 'No doctors available';

  @override
  String get home => 'Home';

  @override
  String get appointment => 'Appointment';

  @override
  String get profile => 'Profile';

  @override
  String get viewYourHealthRecords => 'View your health records';

  @override
  String get activeAlerts => 'Active Alerts';

  @override
  String get consultationHistory => 'Consultation History';

  @override
  String get diagnosed => 'Diagnosed';

  @override
  String get followUp => 'Follow-up';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get temperature => 'Temperature';

  @override
  String get weight => 'Weight';

  @override
  String get latestVitals => 'Latest Vitals';

  @override
  String get allergies => 'Allergies';

  @override
  String get conditions => 'Conditions';

  @override
  String get immunisations => 'Immunisations';

  @override
  String get familyHistory => 'Family History';

  @override
  String get couldNotLoadRecord => 'Could not load record';

  @override
  String get prescriptions => 'Prescriptions';

  @override
  String get noPrescriptions => 'No prescriptions yet.';

  @override
  String couldNotLoadPrescriptions(Object error) {
    return 'Could not load prescriptions: $error';
  }

  @override
  String get prescription => 'Prescription';

  @override
  String get notes => 'Notes';

  @override
  String get medicines => 'Medicines';

  @override
  String get oneMedicine => '1 medicine';

  @override
  String medicinesCount(Object count) {
    return '$count medicines';
  }

  @override
  String get followUpLabel => 'Follow-up:';

  @override
  String get doctorTitle => 'Dr.';

  @override
  String get unknownDoctor => 'Unknown Doctor';

  @override
  String get days => 'days';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get phoneInvalid => 'Phone number must be 10 digits.';

  @override
  String get ageMinimum18 => 'You must be at least 18 years old.';

  @override
  String get noInternetConnection => 'No internet connection. Please try again.';

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String get verifyEmailMessage => 'Account created. Please verify your email before login.';

  @override
  String get emailNotVerifiedTitle => 'Email Not Verified';

  @override
  String get emailNotVerifiedMessage => 'Please verify your email before logging in.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get send => 'Send';

  @override
  String get passwordResetSent => 'Password reset link sent to your email.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get emailNotVerified => 'Email not verified. Please check your inbox.';

  @override
  String get enterEmailForReset => 'enterEmailForReset';

  @override
  String get forgotPassword => 'forgotPassword';

  @override
  String get orSignInWith => 'Or SignIn With';
}
