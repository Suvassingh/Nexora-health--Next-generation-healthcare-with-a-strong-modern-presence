// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'टेलिमेडिकल एप';

  @override
  String get login => 'लगइन ';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get donthaveanaccout => 'खाता छैन?';

  @override
  String get signup => 'साइन अप';

  @override
  String get bookAppointment => 'अपोइन्टमेन्ट\nबुक गर्नुहोस्';

  @override
  String get doctor => 'डाक्टर';

  @override
  String get patient => 'बिरामी';

  @override
  String get homeScreen => 'होम स्क्रिन';

  @override
  String get name => 'पूरा नाम ';

  @override
  String get phone => 'फोन नम्बर';

  @override
  String get age => 'उमेर ';

  @override
  String get gender => 'लिङ्ग';

  @override
  String get address => 'ठेगाना';

  @override
  String get alreadyhaveanaccount => 'पहिले नै खाता छ ?';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get others => 'अन्य';

  @override
  String get confirmpassword => 'पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get next => 'अर्को';

  @override
  String get back => 'फिर्ता';

  @override
  String get loading => 'लोड हुँदै';

  @override
  String get namaste => 'नमस्ते';

  @override
  String get howareyoufeelingtoday => 'आज तपाईंलाई कस्तो महसुस भइरहेको छ?';

  @override
  String get edit => 'सम्पादन';

  @override
  String get goodMorning => 'शुभ बिहान';

  @override
  String get goodAfternoon => 'शुभ दिउँसो';

  @override
  String get goodEvening => 'शुभ साँझ';

  @override
  String get cancelAppointmentTitle => 'अपोइन्टमेन्ट रद्द गर्नुहोस्?';

  @override
  String cancelAppointmentConfirm(String doctorName) {
    return 'डा. $doctorName सँगको अपोइन्टमेन्ट रद्द गर्न चाहनुहुन्छ?';
  }

  @override
  String get no => 'नहोस्';

  @override
  String get cancelConfirmBtn => 'रद्द गर्नुहोस्';

  @override
  String get cancel => 'रद्द';

  @override
  String get cancelBtn => 'रद्द गर्नुहोस्';

  @override
  String get retry => 'पुन: प्रयास';

  @override
  String get book => 'बुक';

  @override
  String get viewAll => 'सबै हेर्नुहोस्';

  @override
  String get upcomingAppointment => 'आउँदो अपोइन्टमेन्ट';

  @override
  String get noUpcomingAppointment => 'कुनै आउँदो अपोइन्टमेन्ट छैन';

  @override
  String get bookNewAppointmentHint => 'नयाँ अपोइन्टमेन्ट बुक गर्न तलको बटन थिच्नुहोस्';

  @override
  String get totalConsultations => 'कुल परामर्श';

  @override
  String get thisMonth => 'यो महिना';

  @override
  String get upcoming => 'आउँदो';

  @override
  String get thisWeekAppointments => 'यो हप्ता अपोइन्टमेन्ट';

  @override
  String get findDoctor => 'डाक्टर खोज्नुहोस्';

  @override
  String get recentAppointments => 'हालका अपोइन्टमेन्ट';

  @override
  String get noAppointmentsYet => 'अहिलेसम्म कुनै अपोइन्टमेन्ट छैन';

  @override
  String get video => 'भिडियो';

  @override
  String get audio => 'अडियो';

  @override
  String get chat => 'च्याट';

  @override
  String get emergencyContact => 'आपतकालीन\nसम्पर्क';

  @override
  String get numberLabel => 'नम्बर:';

  @override
  String get confirmCall => 'यो नम्बरमा कल गर्न चाहनुहुन्छ?';

  @override
  String get callBtn => 'कल गर्नुहोस्';

  @override
  String get numberCopied => 'नम्बर कपी गरियो';

  @override
  String numberCopiedToClipboard(String number) {
    return '$number क्लिपबोर्डमा कपी गरियो';
  }

  @override
  String get save => 'सुरक्षित';

  @override
  String get dateOfBirth => 'जन्म मिति';

  @override
  String get logout => 'लगआउट';

  @override
  String get logoutConfirm => 'के तपाईं लगआउट गर्न चाहनुहुन्छ?';

  @override
  String get changePassword => 'पासवर्ड परिवर्तन गर्नुहोस्';

  @override
  String get consultationType => 'परामर्श प्रकार';

  @override
  String get selectDoctor => 'डाक्टर छान्नुहोस्';

  @override
  String get dateAndTime => 'मिति र समय';

  @override
  String get symptomsAndSummary => 'लक्षण र सारांश';

  @override
  String get bookAppointmentBtn => 'अपॉइन्टमेन्ट बुक गर्नुहोस्';

  @override
  String get nextArrow => 'अर्को →';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफल';

  @override
  String get appointmentBooked => 'अपॉइन्टमेन्ट बुक भयो!';

  @override
  String get ok => 'ठीक छ';

  @override
  String get howToConsult => 'कसरी डाक्टरसँग कुरा गर्न चाहनुहुन्छ?';

  @override
  String get selectConsultationType => 'परामर्श प्रकार छान्नुहोस्';

  @override
  String get selectProvince => 'प्रदेश छान्नुहोस्';

  @override
  String get selectProvinceFirst => 'पहिले प्रदेश छान्नुहोस्';

  @override
  String get selectDistrict => 'जिल्ला छान्नुहोस्';

  @override
  String get selectDistrictFirst => 'पहिले जिल्ला छान्नुहोस्';

  @override
  String get selectMunicipality => 'नगरपालिका (वैकल्पिक)';

  @override
  String get selectProvinceAndDistrict => 'प्रदेश र जिल्ला छान्नुहोस्';

  @override
  String get noDoctorsInArea => 'यस क्षेत्रमा डाक्टर भेटिएन';

  @override
  String get all => 'सबै';

  @override
  String get healthInstitution => 'स्वास्थ्य संस्था';

  @override
  String get date => 'मिति';

  @override
  String get time => 'समय';

  @override
  String get type => 'प्रकार';

  @override
  String get symptomsOptional => 'लक्षणहरू (वैकल्पिक)';

  @override
  String get symptomsHint => 'आफ्नो लक्षण यहाँ लेख्नुहोस्...';

  @override
  String get doctorLoadFailed => 'डाक्टर लोड गर्न सकिएन';

  @override
  String get slotAlreadyBooked => 'यो समय बुक भयो, अर्को छान्नुहोस्।';

  @override
  String get bookingFailed => 'बुकिङ असफल';

  @override
  String get pleaseLoginFirst => 'कृपया पहिले लग इन गर्नुहोस्।';

  @override
  String get myAppointments => 'मेरा अपोइन्टमेन्ट';

  @override
  String get today => 'आज';

  @override
  String get pending => 'पर्खाइमा';

  @override
  String get completed => 'सम्पन्न';

  @override
  String get newBook => 'नयाँ बुक';

  @override
  String get noAppointmentsToday => 'आज कुनै अपोइन्टमेन्ट छैन';

  @override
  String get noPendingAppointments => 'कुनै पर्खाइमा रहेको अपोइन्टमेन्ट छैन';

  @override
  String get noCompletedAppointments => 'कुनै सम्पन्न अपोइन्टमेन्ट छैन';

  @override
  String get noCancelledAppointments => 'कुनै रद्द गरिएको अपोइन्टमेन्ट छैन';

  @override
  String get todaysAppointment => 'आजको अपोइन्टमेन्ट';

  @override
  String get awaitingDoctorConfirmation => 'डाक्टरको पुष्टिको प्रतीक्षामा छ';

  @override
  String get cancelled => 'रद्द';

  @override
  String get appointmentCancelledSuccess => 'अपोइन्टमेन्ट सफलतापूर्वक रद्द गरियो।';

  @override
  String get cancelFailed => 'रद्द गर्न सकिएन';

  @override
  String get actionIrreversible => 'यो कार्य पूर्ववत गर्न सकिँदैन।';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get videoCameraPermission => 'भिडियो कलका लागि क्यामेरा र माइक्रोफोन अनुमति चाहिन्छ।';

  @override
  String get audioMicPermission => 'अडियो कलका लागि माइक्रोफोन अनुमति चाहिन्छ।';

  @override
  String get doctorIdNotFound => 'डाक्टरको ID भेटिएन। पुन: लोड गर्नुहोस्।';

  @override
  String get callFailed => 'कल सुरु गर्न सकिएन';

  @override
  String get physicalVisit => 'भौतिक भेट';

  @override
  String physicalVisitDetail(String doctorName, String healthpost) {
    return 'डा. $doctorName सँग भौतिक परामर्श – $healthpost';
  }

  @override
  String get joinVideoCall => 'भिडियो कल जोइन गर्नुहोस्';

  @override
  String get joinAudioCall => 'अडियो कल गर्नुहोस्';

  @override
  String get startChat => 'च्याट सुरु गर्नुहोस्';

  @override
  String get viewDetails => 'विवरण हेर्नुहोस्';

  @override
  String get viewLocation => 'स्थान हेर्नुहोस्';

  @override
  String get videoConsultation => 'भिडियो परामर्श';

  @override
  String get phoneConsultation => 'फोन परामर्श';

  @override
  String get messageConsultation => 'सन्देश परामर्श';

  @override
  String get reason => 'कारण';

  @override
  String get appointmentPendingConfirmation => 'यो अपोइन्टमेन्ट अझै डाक्टरले पुष्टि गर्नु बाँकी छ।';

  @override
  String get physical => 'भौतिक';

  @override
  String get dataLoadFailed => 'डेटा लोड गर्न सकिएन';

  @override
  String get connecting => 'जडान हुँदै…';

  @override
  String get connected => 'जडान भयो';

  @override
  String get ringing => 'घन्टी बज्दै…';

  @override
  String get callError => 'कल त्रुटि';

  @override
  String get settingUpCall => 'कल तयार गर्दै…';

  @override
  String get unmute => 'अनम्युट';

  @override
  String get mute => 'म्युट';

  @override
  String get camOn => 'क्याम चालु';

  @override
  String get camOff => 'क्याम बन्द';

  @override
  String get speaker => 'स्पिकर';

  @override
  String get earpiece => 'इयरपिस';

  @override
  String get flip => 'फ्लिप';

  @override
  String get callHistory => 'कल इतिहास';

  @override
  String get noCallsYet => 'अहिलेसम्म कुनै कल छैन';

  @override
  String get strengthWeak => 'कमजोर';

  @override
  String get strengthFair => 'ठीकठाक';

  @override
  String get strengthGood => 'राम्रो';

  @override
  String get strengthExcellent => 'उत्कृष्ट';

  @override
  String get emailNotFound => 'ईमेल फेला परेन';

  @override
  String get currentPasswordWrong => 'हालको पासवर्ड गलत छ';

  @override
  String get passwordChangedSuccess => 'पासवर्ड सफलतापूर्वक परिवर्तन भयो';

  @override
  String get somethingWentWrong => 'केही गलत भयो';

  @override
  String get passwordSecurityInfo => 'सुरक्षाको लागि, पहिले आफ्नो हालको पासवर्ड प्रविष्ट गर्नुहोस्। नयाँ पासवर्ड कम्तीमा ८ अक्षरको हुनुपर्छ।';

  @override
  String get currentPassword => 'हालको पासवर्ड';

  @override
  String get currentPasswordHint => 'हालको पासवर्ड लेख्नुहोस्';

  @override
  String get currentPasswordRequired => 'हालको पासवर्ड आवश्यक छ';

  @override
  String get newPassword => 'नयाँ पासवर्ड';

  @override
  String get newPasswordHint => 'नयाँ पासवर्ड लेख्नुहोस्';

  @override
  String get newPasswordRequired => 'नयाँ पासवर्ड आवश्यक छ';

  @override
  String get minEightChars => 'कम्तीमा ८ अक्षर हुनुपर्छ';

  @override
  String get passwordMustDiffer => 'नयाँ पासवर्ड हालको भन्दा फरक हुनुपर्छ';

  @override
  String get repeatPasswordHint => 'पासवर्ड दोहोर्याउनुहोस्';

  @override
  String get confirmPasswordRequired => 'पासवर्ड पुष्टि आवश्यक छ';

  @override
  String get passwordMismatch => 'पासवर्ड मेल खाएन';

  @override
  String get passwordStrength => 'पासवर्ड शक्ति';

  @override
  String get passwordTipsTitle => 'सुरक्षित पासवर्डका लागि:';

  @override
  String get tipMinChars => 'कम्तीमा ८ अक्षर प्रयोग गर्नुहोस्';

  @override
  String get tipMixCase => 'ठूलो र सानो अक्षर मिसाउनुहोस् (A–Z, a–z)';

  @override
  String get tipIncludeNumbers => 'अंक समावेश गर्नुहोस् (0–9)';

  @override
  String get tipSpecialChars => 'विशेष चिह्न थप्नुहोस् (!@#\$%)';

  @override
  String get chatInitFailed => 'च्याट सुरु गर्न सकिएन';

  @override
  String get mediaUploadFailed => 'मिडिया पठाउन सकिएन';

  @override
  String get typeAMessage => 'सन्देश टाइप गर्नुहोस्…';

  @override
  String get messages => 'सन्देशहरू';

  @override
  String get failedToLoadChats => 'च्याट लोड गर्न सकिएन';

  @override
  String get noChatsYet => 'अहिलेसम्म कुनै च्याट छैन';

  @override
  String get bookChatAppointmentHint => 'डाक्टरसँग सन्देश गर्न च्याट अपोइन्टमेन्ट बुक गर्नुहोस्।';

  @override
  String get doctorPrefix => 'डा.';

  @override
  String get emailRequired => 'कृपया आफ्नो ईमेल लेख्नुहोस्';

  @override
  String get passwordRequired => 'कृपया आफ्नो पासवर्ड लेख्नुहोस्';

  @override
  String get loginFailed => 'लगइन असफल';

  @override
  String get loggingIn => 'लगइन हुँदै...';

  @override
  String get personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get accountInfo => 'खाता जानकारी';

  @override
  String get orSignupWith => 'वा यसद्वारा साइन अप गर्नुहोस्';

  @override
  String get google => 'गुगल';

  @override
  String get creatingAccount => 'खाता बनाउँदै...';

  @override
  String get nameRequired => 'नाम आवश्यक छ';

  @override
  String get phoneRequired => 'फोन आवश्यक छ';

  @override
  String get ageRequired => 'उमेर आवश्यक छ';

  @override
  String get genderRequired => 'लिङ्ग आवश्यक छ';

  @override
  String get addressRequired => 'ठेगाना आवश्यक छ';

  @override
  String get passwordMinSix => 'पासवर्ड कम्तीमा ६ अक्षरको हुनुपर्छ';

  @override
  String get signUpFailed => 'साइन अप असफल';

  @override
  String get accountCreated => 'खाता सफलतापूर्वक बनाइयो!';

  @override
  String get accountSetupComplete => 'खाता सेटअप पूरा भयो!';

  @override
  String get emailAlreadyRegistered => 'यो ईमेल पहिले नै दर्ता छ। कृपया लगइन गर्नुहोस्।';

  @override
  String get incompleteProfile => 'प्रोफाइल अपूर्ण';

  @override
  String get completeProfileHint => 'कृपया सेटिङमा गएर आफ्नो प्रोफाइल पूरा गर्नुहोस्।';

  @override
  String get googleSignInFailed => 'गुगल साइन-इन असफल';

  @override
  String get notifications => 'सूचनाहरू';

  @override
  String get markAllRead => 'सबै पढियो';

  @override
  String get noNotifications => 'कुनै सूचना छैन';

  @override
  String get available => 'उपलब्ध';

  @override
  String get busy => 'व्यस्त';

  @override
  String get sun => 'आइत';

  @override
  String get mon => 'सोम';

  @override
  String get tue => 'मंगल';

  @override
  String get wed => 'बुध';

  @override
  String get thu => 'बिहि';

  @override
  String get fri => 'शुक्र';

  @override
  String get sat => 'शनि';

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फेब्रुअरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रिल';

  @override
  String get may => 'मे';

  @override
  String get june => 'जुन';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्ट';

  @override
  String get september => 'सेप्टेम्बर';

  @override
  String get october => 'अक्टोबर';

  @override
  String get november => 'नोभेम्बर';

  @override
  String get december => 'डिसेम्बर';

  @override
  String get selectDateAndTime => 'मिति र समय छान्नुहोस्';

  @override
  String get selectTime => 'समय छान्नुहोस्';

  @override
  String get morning => 'बिहान';

  @override
  String get afternoon => 'दिउँसो';

  @override
  String get selectDateFirst => 'पहिले मिति छान्नुहोस्';

  @override
  String get statusConfirmed => 'पुष्टि';

  @override
  String get statusPending => 'पर्खाइ';

  @override
  String get statusCompleted => 'सम्पन्न';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get statusNoShow => 'गैरहाजिर';

  @override
  String get noMessagesYet => 'अहिलेसम्म कुनै सन्देश छैन';

  @override
  String get tapToStartChatting => 'कुराकानी सुरु गर्न थिच्नुहोस्';

  @override
  String get newLabel => 'नयाँ';

  @override
  String get justNow => 'अहिले मात्र';

  @override
  String minutesAgo(int count) {
    return '$count मिनेट अघि';
  }

  @override
  String daysAgo(int count) {
    return '$count दिन अघि';
  }

  @override
  String get couldNotLoadData => 'डेटा लोड गर्न सकिएन';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get verified => 'सत्यापित';

  @override
  String get ageAndDob => 'उमेर / जन्म मिति';

  @override
  String get bloodGroup => 'रगत समूह';

  @override
  String get select => 'छान्नुस्';

  @override
  String get medicalHistory => 'चिकित्सा इतिहास';

  @override
  String get add => 'थप्नुस्';

  @override
  String get noRecords => 'कुनै रेकर्ड छैन';

  @override
  String get addCondition => 'रोग थप्नुस्';

  @override
  String get conditionHint => 'जस्तै: Hypertension';

  @override
  String get settings => 'सेटिङ';

  @override
  String get language => 'भाषा / Language';

  @override
  String get nepali => 'नेपाली';

  @override
  String get lowDataMode => 'कम डेटा मोड';

  @override
  String get lowDataModeSubtitle => 'Low Data Mode';

  @override
  String get notLoggedIn => 'लगइन छैन';

  @override
  String get profileSaved => 'प्रोफाइल सुरक्षित गरियो ✓';

  @override
  String failedToSave(String error) {
    return 'सुरक्षित गर्न सकिएन: $error';
  }

  @override
  String get selectDateOfBirth => 'जन्म मिति छान्नुहोस्';

  @override
  String get appointmentCancelled => 'अपोइन्टमेन्ट रद्द गरियो।';

  @override
  String get noUpcomingAppointments => 'कुनै आउँदो अपोइन्टमेन्ट छैन';

  @override
  String get cancelAction => 'रद्द गर्नुहोस्';

  @override
  String get seeAll => 'सबै हेर्नुहोस्';

  @override
  String get noDoctorsAvailable => 'डाक्टर उपलब्ध छैनन्';

  @override
  String get home => 'गृह';

  @override
  String get appointment => 'अपोइन्टमेन्ट';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get viewYourHealthRecords => 'आफ्नो स्वास्थ्य रेकर्ड हेर्नुहोस्';

  @override
  String get activeAlerts => 'सक्रिय चेतावनीहरू';

  @override
  String get consultationHistory => 'परामर्श इतिहास';

  @override
  String get diagnosed => 'निदान गरिएको';

  @override
  String get followUp => 'फलो-अप';

  @override
  String get bloodPressure => 'रक्तचाप';

  @override
  String get heartRate => 'मुटुको धड्कन';

  @override
  String get temperature => 'तापक्रम';

  @override
  String get weight => 'तौल';

  @override
  String get latestVitals => 'हालैका जीवन संकेतहरू';

  @override
  String get allergies => 'एलर्जीहरू';

  @override
  String get conditions => 'स्वास्थ्य अवस्थाहरू';

  @override
  String get immunisations => 'खोपहरू';

  @override
  String get familyHistory => 'पारिवारिक स्वास्थ्य इतिहास';

  @override
  String get couldNotLoadRecord => 'रेकर्ड लोड गर्न सकिएन';

  @override
  String get prescriptions => 'प्रिस्क्रिप्सनहरू';

  @override
  String get noPrescriptions => 'अहिलेसम्म कुनै प्रिस्क्रिप्सन छैन।';

  @override
  String couldNotLoadPrescriptions(Object error) {
    return 'प्रिस्क्रिप्सन लोड गर्न सकिएन: $error';
  }

  @override
  String get prescription => 'प्रिस्क्रिप्सन';

  @override
  String get notes => 'टिप्पणीहरू';

  @override
  String get medicines => 'औषधिहरू';

  @override
  String get oneMedicine => '१ औषधि';

  @override
  String medicinesCount(Object count) {
    return '$count औषधिहरू';
  }

  @override
  String get followUpLabel => 'फलो-अप:';

  @override
  String get doctorTitle => 'डा.';

  @override
  String get unknownDoctor => 'अज्ञात डाक्टर';

  @override
  String get days => 'दिन';
}
