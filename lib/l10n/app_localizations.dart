import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Telemedical App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @donthaveanaccout.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account ?'**
  String get donthaveanaccout;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book\nAppointment'**
  String get bookAppointment;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreen;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @alreadyhaveanaccount.
  ///
  /// In en, this message translates to:
  /// **'Already Have An Account ?'**
  String get alreadyhaveanaccount;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get others;

  /// No description provided for @confirmpassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmpassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @namaste.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get namaste;

  /// No description provided for @howareyoufeelingtoday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howareyoufeelingtoday;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @cancelAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment?'**
  String get cancelAppointmentTitle;

  /// No description provided for @cancelAppointmentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the appointment with Dr. {doctorName}?'**
  String cancelAppointmentConfirm(String doctorName);

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancelConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get cancelConfirmBtn;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @upcomingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointment'**
  String get upcomingAppointment;

  /// No description provided for @noUpcomingAppointment.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointment;

  /// No description provided for @bookNewAppointmentHint.
  ///
  /// In en, this message translates to:
  /// **'Press the button below to book a new appointment'**
  String get bookNewAppointmentHint;

  /// No description provided for @totalConsultations.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalConsultations;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @thisWeekAppointments.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekAppointments;

  /// No description provided for @findDoctor.
  ///
  /// In en, this message translates to:
  /// **'Find a Doctor'**
  String get findDoctor;

  /// No description provided for @recentAppointments.
  ///
  /// In en, this message translates to:
  /// **'Recent Appointments'**
  String get recentAppointments;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointmentsYet;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency\nContact'**
  String get emergencyContact;

  /// No description provided for @numberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number:'**
  String get numberLabel;

  /// No description provided for @confirmCall.
  ///
  /// In en, this message translates to:
  /// **'Do you want to call this number?'**
  String get confirmCall;

  /// No description provided for @callBtn.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callBtn;

  /// No description provided for @numberCopied.
  ///
  /// In en, this message translates to:
  /// **'Number Copied'**
  String get numberCopied;

  /// No description provided for @numberCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{number} copied to clipboard'**
  String numberCopiedToClipboard(String number);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @consultationType.
  ///
  /// In en, this message translates to:
  /// **'Consultation Type'**
  String get consultationType;

  /// No description provided for @selectDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get selectDoctor;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @symptomsAndSummary.
  ///
  /// In en, this message translates to:
  /// **'Symptoms & Summary'**
  String get symptomsAndSummary;

  /// No description provided for @bookAppointmentBtn.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointmentBtn;

  /// No description provided for @nextArrow.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get nextArrow;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @appointmentBooked.
  ///
  /// In en, this message translates to:
  /// **'Appointment Booked!'**
  String get appointmentBooked;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @howToConsult.
  ///
  /// In en, this message translates to:
  /// **'How would you like to consult?'**
  String get howToConsult;

  /// No description provided for @selectConsultationType.
  ///
  /// In en, this message translates to:
  /// **'Select a consultation type'**
  String get selectConsultationType;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// No description provided for @selectProvinceFirst.
  ///
  /// In en, this message translates to:
  /// **'Select Province first'**
  String get selectProvinceFirst;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectDistrictFirst.
  ///
  /// In en, this message translates to:
  /// **'Select District first'**
  String get selectDistrictFirst;

  /// No description provided for @selectMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality (optional)'**
  String get selectMunicipality;

  /// No description provided for @selectProvinceAndDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select province and district'**
  String get selectProvinceAndDistrict;

  /// No description provided for @noDoctorsInArea.
  ///
  /// In en, this message translates to:
  /// **'No doctors found in this area'**
  String get noDoctorsInArea;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @healthInstitution.
  ///
  /// In en, this message translates to:
  /// **'Health Institution'**
  String get healthInstitution;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @symptomsOptional.
  ///
  /// In en, this message translates to:
  /// **'Symptoms (optional)'**
  String get symptomsOptional;

  /// No description provided for @symptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Write your symptoms here...'**
  String get symptomsHint;

  /// No description provided for @doctorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load doctors'**
  String get doctorLoadFailed;

  /// No description provided for @slotAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'This slot is taken, please choose another.'**
  String get slotAlreadyBooked;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingFailed;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first.'**
  String get pleaseLoginFirst;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @newBook.
  ///
  /// In en, this message translates to:
  /// **'New Book'**
  String get newBook;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get noAppointmentsToday;

  /// No description provided for @noPendingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No pending appointments'**
  String get noPendingAppointments;

  /// No description provided for @noCompletedAppointments.
  ///
  /// In en, this message translates to:
  /// **'No completed appointments'**
  String get noCompletedAppointments;

  /// No description provided for @noCancelledAppointments.
  ///
  /// In en, this message translates to:
  /// **'No cancelled appointments'**
  String get noCancelledAppointments;

  /// No description provided for @todaysAppointment.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointment'**
  String get todaysAppointment;

  /// No description provided for @awaitingDoctorConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting doctor confirmation'**
  String get awaitingDoctorConfirmation;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @appointmentCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment successfully cancelled.'**
  String get appointmentCancelledSuccess;

  /// No description provided for @cancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get cancelFailed;

  /// No description provided for @actionIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionIrreversible;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @videoCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera and microphone permission required for video call.'**
  String get videoCameraPermission;

  /// No description provided for @audioMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required for audio call.'**
  String get audioMicPermission;

  /// No description provided for @doctorIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Doctor ID not found. Please reload.'**
  String get doctorIdNotFound;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start call'**
  String get callFailed;

  /// No description provided for @physicalVisit.
  ///
  /// In en, this message translates to:
  /// **'Physical Visit'**
  String get physicalVisit;

  /// No description provided for @physicalVisitDetail.
  ///
  /// In en, this message translates to:
  /// **'Physical consultation with Dr. {doctorName} at {healthpost}'**
  String physicalVisitDetail(String doctorName, String healthpost);

  /// No description provided for @joinVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Join Video Call'**
  String get joinVideoCall;

  /// No description provided for @joinAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Join Audio Call'**
  String get joinAudioCall;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewLocation.
  ///
  /// In en, this message translates to:
  /// **'View Location'**
  String get viewLocation;

  /// No description provided for @videoConsultation.
  ///
  /// In en, this message translates to:
  /// **'Video Consultation'**
  String get videoConsultation;

  /// No description provided for @phoneConsultation.
  ///
  /// In en, this message translates to:
  /// **'Phone Consultation'**
  String get phoneConsultation;

  /// No description provided for @messageConsultation.
  ///
  /// In en, this message translates to:
  /// **'Message Consultation'**
  String get messageConsultation;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @appointmentPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This appointment is still awaiting doctor confirmation.'**
  String get appointmentPendingConfirmation;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @dataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get dataLoadFailed;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing…'**
  String get ringing;

  /// No description provided for @callError.
  ///
  /// In en, this message translates to:
  /// **'Call Error'**
  String get callError;

  /// No description provided for @settingUpCall.
  ///
  /// In en, this message translates to:
  /// **'Setting up call…'**
  String get settingUpCall;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @camOn.
  ///
  /// In en, this message translates to:
  /// **'Cam On'**
  String get camOn;

  /// No description provided for @camOff.
  ///
  /// In en, this message translates to:
  /// **'Cam Off'**
  String get camOff;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @earpiece.
  ///
  /// In en, this message translates to:
  /// **'Earpiece'**
  String get earpiece;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @callHistory.
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get callHistory;

  /// No description provided for @noCallsYet.
  ///
  /// In en, this message translates to:
  /// **'No calls yet'**
  String get noCallsYet;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthExcellent;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordWrong;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @passwordSecurityInfo.
  ///
  /// In en, this message translates to:
  /// **'For security, please enter your current password first. The new password must be at least 8 characters.'**
  String get passwordSecurityInfo;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get currentPasswordHint;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get newPasswordHint;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @minEightChars.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 8 characters'**
  String get minEightChars;

  /// No description provided for @passwordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must differ from current'**
  String get passwordMustDiffer;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get passwordStrength;

  /// No description provided for @passwordTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'For a secure password:'**
  String get passwordTipsTitle;

  /// No description provided for @tipMinChars.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get tipMinChars;

  /// No description provided for @tipMixCase.
  ///
  /// In en, this message translates to:
  /// **'Mix uppercase and lowercase (A–Z, a–z)'**
  String get tipMixCase;

  /// No description provided for @tipIncludeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Include numbers (0–9)'**
  String get tipIncludeNumbers;

  /// No description provided for @tipSpecialChars.
  ///
  /// In en, this message translates to:
  /// **'Add special characters (!@#\$%)'**
  String get tipSpecialChars;

  /// No description provided for @chatInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize chat'**
  String get chatInitFailed;

  /// No description provided for @mediaUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send media'**
  String get mediaUploadFailed;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessage;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @failedToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @bookChatAppointmentHint.
  ///
  /// In en, this message translates to:
  /// **'Book a chat appointment to start messaging\nyour doctor.'**
  String get bookChatAppointmentHint;

  /// No description provided for @doctorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get doctorPrefix;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in…'**
  String get loggingIn;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @orSignupWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignupWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get creatingAccount;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get genderRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @passwordMinSix.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinSix;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Failed'**
  String get signUpFailed;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @accountSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Account setup complete. Please login.'**
  String get accountSetupComplete;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please login instead.'**
  String get emailAlreadyRegistered;

  /// No description provided for @incompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Profile'**
  String get incompleteProfile;

  /// No description provided for @completeProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile information.'**
  String get completeProfileHint;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In Failed'**
  String get googleSignInFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateAndTime;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @selectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date first'**
  String get selectDateFirst;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get statusNoShow;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @tapToStartChatting.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get tapToStartChatting;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @couldNotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Could not load data'**
  String get couldNotLoadData;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @ageAndDob.
  ///
  /// In en, this message translates to:
  /// **'Age / Date of Birth'**
  String get ageAndDob;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecords;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add Condition'**
  String get addCondition;

  /// No description provided for @conditionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hypertension'**
  String get conditionHint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language / भाषा'**
  String get language;

  /// No description provided for @nepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get nepali;

  /// No description provided for @lowDataMode.
  ///
  /// In en, this message translates to:
  /// **'Low Data Mode'**
  String get lowDataMode;

  /// No description provided for @lowDataModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Low Data Mode'**
  String get lowDataModeSubtitle;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved ✓'**
  String get profileSaved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String failedToSave(String error);

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirth;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled.'**
  String get appointmentCancelled;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noDoctorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No doctors available'**
  String get noDoctorsAvailable;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointment;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @viewYourHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'View your health records'**
  String get viewYourHealthRecords;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @consultationHistory.
  ///
  /// In en, this message translates to:
  /// **'Consultation History'**
  String get consultationHistory;

  /// No description provided for @diagnosed.
  ///
  /// In en, this message translates to:
  /// **'Diagnosed'**
  String get diagnosed;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @latestVitals.
  ///
  /// In en, this message translates to:
  /// **'Latest Vitals'**
  String get latestVitals;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @immunisations.
  ///
  /// In en, this message translates to:
  /// **'Immunisations'**
  String get immunisations;

  /// No description provided for @familyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get familyHistory;

  /// No description provided for @couldNotLoadRecord.
  ///
  /// In en, this message translates to:
  /// **'Could not load record'**
  String get couldNotLoadRecord;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @noPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions yet.'**
  String get noPrescriptions;

  /// No description provided for @couldNotLoadPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Could not load prescriptions: {error}'**
  String couldNotLoadPrescriptions(Object error);

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @oneMedicine.
  ///
  /// In en, this message translates to:
  /// **'1 medicine'**
  String get oneMedicine;

  /// No description provided for @medicinesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} medicines'**
  String medicinesCount(Object count);

  /// No description provided for @followUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow-up:'**
  String get followUpLabel;

  /// No description provided for @doctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get doctorTitle;

  /// No description provided for @unknownDoctor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Doctor'**
  String get unknownDoctor;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits.'**
  String get phoneInvalid;

  /// No description provided for @ageMinimum18.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old.'**
  String get ageMinimum18;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get noInternetConnection;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created. Please verify your email before login.'**
  String get verifyEmailMessage;

  /// No description provided for @emailNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerifiedTitle;

  /// No description provided for @emailNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in.'**
  String get emailNotVerifiedMessage;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email.'**
  String get passwordResetSent;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'enterEmailForReset'**
  String get enterEmailForReset;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'forgotPassword'**
  String get forgotPassword;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or SignIn With'**
  String get orSignInWith;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ne': return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
