import 'dart:async';
import 'package:quiver/time.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import './storage.dart';

abstract class DataStarsService {
  Future<List<Star>> getStars({
    required int id,
    required DateScope scope,
  });
  Future<Star?> getTodayStars({
    required int id,
    required int progressLimit,
  });
  Future<bool> updateStars({
    required int recordId,
    required int stars,
  });
  Future<bool> updateLastUserStars({
    required int userId,
    required int stars,
  });
  Future<int> insertStarsDay({
    required Star star,
  });
  Future<bool> updateStarsLimit({
    required int recordId,
    required int stars,
    required int limit,
  });
  Future<Star?> insertStar({
    required int userId,
    required int stars,
    required int limit,
    required String date,
  });
}

class StarsService extends DataStarsService {
  @override
  Future<List<Star>> getStars({
    required int id,
    required DateScope scope,
    int offset = 0,
    bool isNullStarIncluded = true,
  }) async {
    StorageService storageService = StorageService();

    final db = await storageService.getDatabase();

    List<Star> stars = [];

    try {
      List<Map<String, dynamic>> starsList = [];
      starsList = await db
          .rawQuery("SELECT * FROM stars WHERE userId = $id ORDER BY pk");

      List<String> dates = [];
      List<Star> result = [];
      DateTime now = DateTime.now();

      if (scope == DateScope.week) {
        DateTime monday = now.add(Duration(days: -(now.weekday - 1)));

        for (int i = 0; i <= 6; i++) {
          dates.add(
            DateParser(date: monday.add(Duration(days: i - (7 * offset))))
                .getDateWithoutTime(),
          );
        }
      } else if (scope == DateScope.month) {
        int year = now.year;
        int month = now.month;

        if (offset > 0) {
          if (offset % 12 == 0) {
            int yearOffset = offset ~/ 12;
            year = year - yearOffset;
          } else if (offset < 12) {
            if (month - offset < 0) {
              year = year - 1;
              month = 12 + month - offset;
            } else if (month - offset == 0) {
              year = year - 1;
              month = 12;
            } else {
              month = month - offset;
            }
          } else {
            year = year - (offset / 12).floor();
            int rest = (offset % 12);

            if (month - rest < 0) {
              year = year - 1;
              month = 12 + month - rest;
            } else if (month - rest == 0) {
              year = year - 1;
              month = 12;
            } else {
              month = month - rest;
            }
          }
        }

        int days = daysInMonth(
          year,
          month,
        );

        for (int i = 1; i <= days; i++) {
          dates.add(
            '${i < 10 ? '0$i' : i}-${month < 10 ? '0$month' : month}-$year',
          );
        }
      }

      if (starsList.isNotEmpty) {
        List<Star> starsFound = [];

        for (var star in starsList) {
          starsFound.add(Star.fromJson(star));
        }

        for (var date in dates) {
          Star? _star = starsFound.firstWhere(
            (element) => element.date == date,
            orElse: () {
              return Star(
                date: date,
                userId: starsFound.last.userId,
                stars: 0,
                progressLimit: starsFound.last.progressLimit,
              );
            },
          );
          result.add(_star);
        }
      }

      if (scope == DateScope.month) {
        List<List<Star>> weekList = [];
        List<Star> sortedStars = [];
        int chunkSize = 7;

        for (int i = 0; i < result.length; i += chunkSize) {
          weekList.add(
            result.sublist(
              i,
              i + chunkSize > result.length ? result.length : i + chunkSize,
            ),
          );
        }

        for (var list in weekList) {
          int stars = 0;
          int limit = 0;

          for (var star in list) {
            stars += star.stars;
            limit += star.progressLimit;
          }

          if (stars > 0) {
            sortedStars.add(Star(
              date: list.first.date,
              stars: (stars / list.length).floor(),
              progressLimit: (limit / list.length).floor(),
              userId: list.first.userId,
            ));
          } else {
            sortedStars.add(Star(
              date: list.first.date,
              stars: 0,
              progressLimit: (limit / list.length).floor(),
              userId: list.first.userId,
            ));
          }

          result = sortedStars;
        }
      }

      return result;
    } catch (e) {
      print(e);
    }
    return stars;
  }

  @override
  Future<Star?> getTodayStars({
    required int id,
    required int progressLimit,
  }) async {
    StorageService storageService = StorageService();

    try {
      final db = await storageService.getDatabase();

      DateTime now = DateTime.now();
      DateParser date = DateParser(date: now);
      String parsedDate = date.getDateWithoutTime();

      List<Map<String, dynamic>> starsList = [];

      starsList = await db.rawQuery(
          "SELECT * FROM stars WHERE userId = $id AND date = '$parsedDate'");

      if (starsList.isEmpty) {
        Star _emptyStars = Star(
          date: parsedDate,
          userId: id,
          progressLimit: progressLimit,
          stars: 0,
        );

        Star _resultStar = await db
            .insert(
          'stars',
          _emptyStars.toJson(),
        )
            .then(
          (value) {
            int pk = value;

            return Star(
              id: pk,
              date: _emptyStars.date,
              userId: _emptyStars.userId,
              progressLimit: _emptyStars.progressLimit,
              stars: _emptyStars.stars,
            );
          },
        );

        return _resultStar;
      } else {
        Star star = Star.fromJson(starsList.last);
        return star;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateStars({
    required int recordId,
    required int stars,
  }) async {
    StorageService storageService = StorageService();

    try {
      final db = await storageService.getDatabase();

      int count = await db.rawUpdate(
        'UPDATE stars SET stars = ? WHERE pk = ?',
        [stars, recordId],
      );

      print('UPDATED STARS: id $recordId count $count');
      return count > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> updateLastUserStars({
    required int userId,
    required int stars,
  }) async {
    StorageService storageService = StorageService();

    try {
      List<Map<String, dynamic>> starsList = [];

      final db = await storageService.getDatabase();
      starsList = await db.rawQuery(
          "SELECT * FROM stars WHERE userId = $userId ORDER BY pk DESC LIMIT 1");

      if (starsList.isNotEmpty) {
        Star tempStar = Star.fromJson(starsList.last);

        int count = await db.rawUpdate(
          'UPDATE stars SET progressLimit = ? WHERE pk = ?',
          [stars, tempStar.id],
        );

        print('UPDATED STARS: id ${tempStar.id} count $count');
        return count > 0;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<int> insertStarsDay({
    required Star star,
  }) async {
    StorageService storageService = StorageService();

    try {
      final db = await storageService.getDatabase();
      int id = await db
          .insert(
        'stars',
        star.toJson(),
      )
          .then((value) {
        return value;
      });

      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  @override
  Future<bool> updateStarsLimit({
    required int recordId,
    required int stars,
    required int limit,
  }) async {
    StorageService storageService = StorageService();

    try {
      final db = await storageService.getDatabase();

      int count = await db.rawUpdate(
        'UPDATE stars SET stars = ?, progressLimit = ? WHERE pk = ?',
        [stars, limit, recordId],
      );

      print('UPDATED STARS: id $recordId count $count');
      return count > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<Star?> insertStar({
    required int userId,
    required int stars,
    required int limit,
    required String date,
  }) async {
    StorageService storageService = StorageService();
    Star newStar = Star(
      date: date,
      userId: userId,
      stars: stars,
      progressLimit: limit,
    );

    try {
      final db = await storageService.getDatabase();

      Star _resultStar = await db
          .insert(
        'stars',
        newStar.toJson(),
      )
          .then(
        (value) {
          int pk = value;

          return Star(
            id: pk,
            date: date,
            userId: userId,
            progressLimit: limit,
            stars: stars,
          );
        },
      );

      return _resultStar;
    } catch (e) {
      print(e);
    }
  }
}
