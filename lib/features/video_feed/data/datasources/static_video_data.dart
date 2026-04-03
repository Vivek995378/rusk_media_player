import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';

class StaticVideoData {
  static final List<VideoEntity> videos = [
    VideoEntity(
      id: 'vid_01',
      username: 'ruskmediaofficial',
      description: 'Morning ride hits different 🚴‍♂️ #RuskOriginal',
      videoUrl:
          'https://res.cloudinary.com/dxl93ott6/video/upload/v1775223169/Video-148_jmfeym.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=21',
      likeCount: 1820,
      commentCount: 142,
      shareCount: 96,
      isLiked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_02',
      username: 'ruskmediafans',
      description: 'POV: you finally take a break ✨ #FanEdit',
      videoUrl:
          'https://res.cloudinary.com/dxl93ott6/video/upload/v1775223169/Video-995_dqwfmc.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=22',
      likeCount: 5420,
      commentCount: 389,
      shareCount: 210,
      isBookmarked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_03',
      username: 'ruskmedia.tech',
      description: 'Late night coding session 💻☕ #CreatorLife',
      videoUrl:
          'https://res.cloudinary.com/dkvfdusmb/video/upload/v1743853238/videoplayback7_zljhzl.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=23',
      likeCount: 3210,
      commentCount: 275,
      shareCount: 143,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_04',
      username: 'ruskmedia.fitness',
      description: 'No excuses. Just consistency 💪 #StayFit',
      videoUrl:
          'https://res.cloudinary.com/dxl93ott6/video/upload/v1775223168/Video-732_1_1_1_fdqbot.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=24',
      likeCount: 8740,
      commentCount: 610,
      shareCount: 355,
      isLiked: true,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_05',
      username: 'ruskmedia.travel',
      description: 'This view was worth the climb 🏔️ #ExploreMore',
      videoUrl:
          'https://res.cloudinary.com/dxl93ott6/video/upload/v1775223169/Video-148_jmfeym.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=25',
      likeCount: 6520,
      commentCount: 420,
      shareCount: 280,
      timestamp: DateTime(2026, 4, 3),
    ),

    VideoEntity(
      id: 'vid_06',
      username: 'ruskmedia.food',
      description: 'Street food never disappoints 🤤 #FoodReels',
      videoUrl:
          'https://res.cloudinary.com/dxl93ott6/video/upload/v1775223169/Video-714_1_woh4tl.mp4',
      profileImageUrl: 'https://i.pravatar.cc/150?img=26',
      likeCount: 4980,
      commentCount: 312,
      shareCount: 190,
      isLiked: true,
      isBookmarked: true,
      timestamp: DateTime(2026, 4, 3),
    ),
  ];
}
