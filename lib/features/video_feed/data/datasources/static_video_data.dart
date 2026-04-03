import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';

class StaticVideoData {
  static final List<VideoEntity> videos = [
    VideoEntity(
      id: 'vid_01',
      username: 'rahul.vlogs',
      description: 'Morning ride hits different 🚴‍♂️',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775220309/Video-148_iudo9d.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=11',
      likeCount: 1820,
      commentCount: 142,
      shareCount: 96,
      isLiked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_02',
      username: 'ananya.lifestyle',
      description: 'POV: you finally take a break ✨',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775221168/Video-714_wdqytm.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=12',
      likeCount: 5420,
      commentCount: 389,
      shareCount: 210,
      isBookmarked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_03',
      username: 'dev.raj',
      description: 'Late night coding session 💻☕',
      videoUrl:
      'https://res.cloudinary.com/dkvfdusmb/video/upload/v1743853238/videoplayback7_zljhzl.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=13',
      likeCount: 3210,
      commentCount: 275,
      shareCount: 143,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_04',
      username: 'fit.with.aman',
      description: 'No excuses. Just consistency 💪',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775221180/Video-995_dj5axx.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=14',
      likeCount: 8740,
      commentCount: 610,
      shareCount: 355,
      isLiked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_05',
      username: 'travel.with.me',
      description: 'This view was worth the climb 🏔️',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775221741/Video-903_1_1_zzhtfx.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=15',
      likeCount: 6520,
      commentCount: 420,
      shareCount: 280,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_06',
      username: 'foodie.diaries',
      description: 'Street food never disappoints 🤤',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775221741/Video-732_1_1_cjnfod.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=16',
      likeCount: 4980,
      commentCount: 312,
      shareCount: 190,
      isLiked: true,
      isBookmarked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_07',
      username: 'music.addict',
      description: 'Headphones on. World off 🎧',
      videoUrl:
      'https://res.cloudinary.com/dxl93ott6/video/upload/v1775221751/Video-181_1_1_vdsywy.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=17',
      likeCount: 7350,
      commentCount: 540,
      shareCount: 320,
      timestamp: DateTime(2026, 4, 3),
    ),
  ];
}