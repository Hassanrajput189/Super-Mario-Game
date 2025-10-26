import 'package:client/boxes.dart';
import 'package:client/widgets/Mushroom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/Mario.dart';
import 'package:client/widgets/MyButton.dart';
import "package:client/widgets/JumpingMario.dart";
import 'package:flutter/material.dart';
import 'package:client/models/progress.dart';
import 'dart:async';
import 'dart:math';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load the high score when the page initializes
    try {
      if (Hive.isBoxOpen('ProgressBox')) {
        final progress = progressBox.get('highScore');
        if (progress != null) {
          setState(() {
            highScore = progress.highScore;
            date = progress.date;
          });
        }
      }
    } catch (e) {
      print('Error loading initial high score: $e');
    }
  }

  double marioX = 0;
  static double marioY = 1.05;
  double mushroomX = 0.5;
  double mushroomY = 1.05;
  double time = 0;
  double hight = 0;
  double initHight = marioY;
  double size = 50;
  String direction = "right";
  bool run = false;
  bool midJump = false;
  bool gameActive = false;
  Timer? gameTimer;
  int remainingSeconds = 60;
  Random random = Random();
  int mushroomCount = 0;
  int highScore = 0;
  DateTime date = DateTime.now();

  var gameFont = GoogleFonts.pressStart2p(
    textStyle: TextStyle(color: Colors.white, fontSize: 20),
  );

  double getBaseHeight() {
    return 1.05 + (size - 50) * 0.002;
  }

  void resetHight() {
    time = 0;
    initHight = marioY;
  }

  void startGame() {
    if (!gameActive) {
      setState(() {
        gameActive = true;
        remainingSeconds = 60;
        mushroomCount = 0;
        size = 50;
        marioY = 1.05;
      });

      gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            endGame();
          }
        });
      });
    }
    try {
      if (Hive.isBoxOpen('ProgressBox')) {
        final progress = progressBox.get('highScore');

        if (progress != null) {
          setState(() {
            highScore = progress.highScore;
            date = progress.date;
          });
        }
      }
    } catch (e) {
      print('Error reading saved progress: $e');
    }
  }

  void endGame() {
    gameTimer?.cancel();
    setState(() {
      gameActive = false;

      // Always save the score when game ends if it's higher
      if (mushroomCount >= highScore) {
        highScore = mushroomCount;
        date = DateTime.now();
        try {
          final progress = Progress(highScore: highScore, date: date);

          // Ensure box is open
          if (!Hive.isBoxOpen('ProgressBox')) {
            progressBox = Hive.box<Progress>('ProgressBox');
          }
          // Save the score
          progressBox.put('highScore', progress);
          // Single flush call is sufficient
          progressBox.flush();
        } catch (e) {
          print('Error saving score: $e');
        }
      }
    });
  }

  void ateMushroom() {
    if ((marioX - mushroomX).abs() < 0.15 &&
        (marioY - mushroomY).abs() < 0.15) {
      setState(() {
        mushroomX = random.nextDouble() * 2 - 1;
        mushroomY = 1 - random.nextDouble() * 0.3;
        size += 10;

        setState(() {
          mushroomCount++;
          marioY = 1.05 + (size - 50) * 0.002;
        });


        if (mushroomCount >= highScore) {
          highScore = mushroomCount;
          date = DateTime.now();
          try {
            final progress = Progress(highScore: highScore, date: date);
            if (Hive.isBoxOpen('ProgressBox')) {
              progressBox.put('highScore', progress);
            }
          } catch (e) {
            print('Error saving high score during gameplay: $e');
          }
        }
      });
    }
  }

  void jump() {
    if (midJump == false && gameActive) {
      midJump = true;

      resetHight();
      Timer.periodic(Duration(milliseconds: 50), (timer) {
        time += 0.05;
        hight = -4.9 * time * time + 5 * time;

        if (initHight - hight > getBaseHeight()) {
          midJump = false;
          setState(() {
            marioY = getBaseHeight();
            timer.cancel();
          });
        } else {
          setState(() {
            marioY = initHight - hight;
            ateMushroom();
          });
        }
      });
    }
  }

  void moveRight() {
    if (!gameActive) return;
    direction = "right";
    ateMushroom();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      ateMushroom();
      if (MyButton().userIsHoldingButton() == true && marioX + 0.02 < 1.10) {
        setState(() {
          marioX += 0.02;
          run = !run;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void moveLeft() {
    if (!gameActive) return;
    direction = "left";
    ateMushroom();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      ateMushroom();
      if (MyButton().userIsHoldingButton() == true && marioX - 0.02 > -1.10) {
        setState(() {
          marioX -= 0.02;
          run = !run;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  color: Colors.blue,
                  child: AnimatedContainer(
                    alignment: Alignment(marioX, marioY),
                    duration: Duration(milliseconds: 0),
                    child: midJump
                        ? JumpingMario(direction: direction, size: size)
                        : Mario(direction: direction, run: run, size: size),
                  ),
                ),
                Container(
                  alignment: Alignment(mushroomX, mushroomY),
                  child: Mushroom(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Name", style: gameFont),
                          SizedBox(height: 5),
                          Text("Mario", style: gameFont),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Mushrooms", style: gameFont),
                          SizedBox(height: 5),
                          Text("$mushroomCount", style: gameFont),
                        ],
                      ),
                      Column(
                        children: [
                          Text("High Score", style: gameFont),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text("$highScore ", style: gameFont),
                              Text(
                                "${date.day}/${date.month}/${date.year}",
                                style: gameFont.copyWith(fontSize: 10),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text("Time", style: gameFont),
                          SizedBox(height: 5),
                          Text("$remainingSeconds", style: gameFont),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.brown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!gameActive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: startGame,
                        child: Text('Start Game',
                            style: gameFont.copyWith(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        function: moveLeft,
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      MyButton(
                        function: jump,
                        child: Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                      MyButton(
                        function: moveRight,
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
