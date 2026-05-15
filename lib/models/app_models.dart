// ─── Event Model ────────────────────────────────────────────────
class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int registered;
  final int capacity;
  final String status;
  final String type;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.registered,
    required this.capacity,
    required this.status,
    required this.type,
  });
}

// ─── Activity Model ─────────────────────────────────────────────
class ActivityModel {
  final String type;
  final String title;
  final String subtitle;
  final String timeAgo;

  const ActivityModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });
}

// ─── Member Model ────────────────────────────────────────────────
class MemberModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'Admin' | 'Member'
  final String club;
  final String joinDate;
  final String status; // 'active' | 'inactive'
  final int attendanceCount;
  final String avatarInitials;

  const MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.club,
    required this.joinDate,
    required this.status,
    required this.attendanceCount,
    required this.avatarInitials,
  });
}

// ─── Attendance Model ────────────────────────────────────────────
class AttendanceModel {
  final String id;
  final String memberName;
  final String eventTitle;
  final String date;
  final String status; // 'present' | 'absent' | 'late'
  final String avatarInitials;

  const AttendanceModel({
    required this.id,
    required this.memberName,
    required this.eventTitle,
    required this.date,
    required this.status,
    required this.avatarInitials,
  });
}

// ─── Material Model ──────────────────────────────────────────────
class MaterialModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'Algorithms' | 'Machine Learning' | 'Web Dev' | 'Python'
  final String fileType; // 'PDF' | 'PPT' | 'DOC' | 'VIDEO'
  final String fileSize;
  final String uploadedBy;
  final String uploadDate;
  final int downloadCount;

  const MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileType,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadDate,
    required this.downloadCount,
  });
}

// ─── Sample Data ─────────────────────────────────────────────────

final List<EventModel> sampleEvents = [
  const EventModel(
    id: '1',
    title: 'Machine Learning Workshop',
    description: 'Introduction to neural networks and deep learning',
    date: 'Thursday, March 5, 2026',
    time: '2:00 PM - 4:00 PM',
    location: 'Room 301',
    registered: 42,
    capacity: 50,
    status: 'confirmed',
    type: 'Workshop',
  ),
  const EventModel(
    id: '2',
    title: 'Algorithms Study Session',
    description: 'Deep dive into sorting and searching algorithms',
    date: 'Saturday, March 7, 2026',
    time: '3:00 PM - 5:00 PM',
    location: 'Library Hall',
    registered: 28,
    capacity: 40,
    status: 'confirmed',
    type: 'Study Session',
  ),
  const EventModel(
    id: '3',
    title: 'Web Development Bootcamp',
    description: 'Full-stack web development fundamentals',
    date: 'Tuesday, March 10, 2026',
    time: '1:00 PM - 5:00 PM',
    location: 'Tech Lab',
    registered: 35,
    capacity: 50,
    status: 'pending',
    type: 'Bootcamp',
  ),
];

final List<ActivityModel> sampleActivities = [
  const ActivityModel(
    type: 'member',
    title: 'New member joined',
    subtitle: 'Sarah Johnson joined Computer Science Club',
    timeAgo: '2 hours ago',
  ),
  const ActivityModel(
    type: 'event',
    title: 'Event completed',
    subtitle: 'Python Workshop - 45 attendees',
    timeAgo: '5 hours ago',
  ),
  const ActivityModel(
    type: 'milestone',
    title: 'Milestone reached',
    subtitle: 'Study club reached 250 members!',
    timeAgo: '1 day ago',
  ),
  const ActivityModel(
    type: 'alert',
    title: 'Low attendance alert',
    subtitle: 'Data Structures session had only 12 attendees',
    timeAgo: '2 days ago',
  ),
];

final List<MemberModel> sampleMembers = [
  const MemberModel(
    id: '1',
    name: 'Sarah Johnson',
    email: 'sarah.j@study.com',
    role: 'Member',
    club: 'Computer Science Club',
    joinDate: 'Jan 10, 2026',
    status: 'active',
    attendanceCount: 12,
    avatarInitials: 'SJ',
  ),
  const MemberModel(
    id: '2',
    name: 'Ahmad Rizky',
    email: 'ahmad.r@study.com',
    role: 'Admin',
    club: 'Machine Learning Club',
    joinDate: 'Dec 5, 2025',
    status: 'active',
    attendanceCount: 20,
    avatarInitials: 'AR',
  ),
  const MemberModel(
    id: '3',
    name: 'Budi Santoso',
    email: 'budi.s@study.com',
    role: 'Member',
    club: 'Web Development Club',
    joinDate: 'Feb 1, 2026',
    status: 'inactive',
    attendanceCount: 3,
    avatarInitials: 'BS',
  ),
  const MemberModel(
    id: '4',
    name: 'Dewi Rahayu',
    email: 'dewi.r@study.com',
    role: 'Member',
    club: 'Algorithms Club',
    joinDate: 'Nov 20, 2025',
    status: 'active',
    attendanceCount: 17,
    avatarInitials: 'DR',
  ),
  const MemberModel(
    id: '5',
    name: 'Eko Prasetyo',
    email: 'eko.p@study.com',
    role: 'Member',
    club: 'Computer Science Club',
    joinDate: 'Mar 1, 2026',
    status: 'active',
    attendanceCount: 8,
    avatarInitials: 'EP',
  ),
  const MemberModel(
    id: '6',
    name: 'Fitri Nuraini',
    email: 'fitri.n@study.com',
    role: 'Member',
    club: 'Machine Learning Club',
    joinDate: 'Jan 25, 2026',
    status: 'active',
    attendanceCount: 14,
    avatarInitials: 'FN',
  ),
];

final List<AttendanceModel> sampleAttendances = [
  const AttendanceModel(
    id: '1',
    memberName: 'Sarah Johnson',
    eventTitle: 'Machine Learning Workshop',
    date: 'Mar 5, 2026',
    status: 'present',
    avatarInitials: 'SJ',
  ),
  const AttendanceModel(
    id: '2',
    memberName: 'Ahmad Rizky',
    eventTitle: 'Machine Learning Workshop',
    date: 'Mar 5, 2026',
    status: 'present',
    avatarInitials: 'AR',
  ),
  const AttendanceModel(
    id: '3',
    memberName: 'Budi Santoso',
    eventTitle: 'Machine Learning Workshop',
    date: 'Mar 5, 2026',
    status: 'absent',
    avatarInitials: 'BS',
  ),
  const AttendanceModel(
    id: '4',
    memberName: 'Dewi Rahayu',
    eventTitle: 'Algorithms Study Session',
    date: 'Mar 7, 2026',
    status: 'late',
    avatarInitials: 'DR',
  ),
  const AttendanceModel(
    id: '5',
    memberName: 'Eko Prasetyo',
    eventTitle: 'Algorithms Study Session',
    date: 'Mar 7, 2026',
    status: 'present',
    avatarInitials: 'EP',
  ),
  const AttendanceModel(
    id: '6',
    memberName: 'Fitri Nuraini',
    eventTitle: 'Web Development Bootcamp',
    date: 'Mar 10, 2026',
    status: 'present',
    avatarInitials: 'FN',
  ),
  const AttendanceModel(
    id: '7',
    memberName: 'Sarah Johnson',
    eventTitle: 'Web Development Bootcamp',
    date: 'Mar 10, 2026',
    status: 'late',
    avatarInitials: 'SJ',
  ),
  const AttendanceModel(
    id: '8',
    memberName: 'Budi Santoso',
    eventTitle: 'Web Development Bootcamp',
    date: 'Mar 10, 2026',
    status: 'absent',
    avatarInitials: 'BS',
  ),
];

final List<MaterialModel> sampleMaterials = [
  const MaterialModel(
    id: '1',
    title: 'Introduction to Neural Networks',
    description: 'Slide deck dari Machine Learning Workshop sesi pertama',
    category: 'Machine Learning',
    fileType: 'PPT',
    fileSize: '4.2 MB',
    uploadedBy: 'Ahmad Rizky',
    uploadDate: 'Mar 5, 2026',
    downloadCount: 38,
  ),
  const MaterialModel(
    id: '2',
    title: 'Sorting Algorithms Cheatsheet',
    description: 'Ringkasan semua algoritma sorting beserta kompleksitasnya',
    category: 'Algorithms',
    fileType: 'PDF',
    fileSize: '1.1 MB',
    uploadedBy: 'Dewi Rahayu',
    uploadDate: 'Mar 7, 2026',
    downloadCount: 52,
  ),
  const MaterialModel(
    id: '3',
    title: 'HTML & CSS Fundamentals',
    description: 'Materi dasar web development untuk pemula',
    category: 'Web Dev',
    fileType: 'PDF',
    fileSize: '2.8 MB',
    uploadedBy: 'Ahmad Rizky',
    uploadDate: 'Mar 10, 2026',
    downloadCount: 44,
  ),
  const MaterialModel(
    id: '4',
    title: 'Python for Data Science',
    description: 'Panduan lengkap Python untuk analisis data',
    category: 'Python',
    fileType: 'DOC',
    fileSize: '3.5 MB',
    uploadedBy: 'Sarah Johnson',
    uploadDate: 'Feb 28, 2026',
    downloadCount: 61,
  ),
  const MaterialModel(
    id: '5',
    title: 'Deep Learning Video Tutorial',
    description: 'Rekaman sesi workshop deep learning',
    category: 'Machine Learning',
    fileType: 'VIDEO',
    fileSize: '120 MB',
    uploadedBy: 'Ahmad Rizky',
    uploadDate: 'Mar 6, 2026',
    downloadCount: 29,
  ),
];