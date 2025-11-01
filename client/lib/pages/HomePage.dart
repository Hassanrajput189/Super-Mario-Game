import 'package:client/widgets/Mushroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/Mario.dart';
import 'package:client/widgets/MyButton.dart';
import "package:client/widgets/JumpingMario.dart";
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final COLLECTION_NAME = "SuperMaio";
  double marioX = 0;
  double marioY = 1.05;
  double mushroomX = 0.5;
  double mushroomY = 1.05;
  double time = 0;
  double height = 0;
  double initHeight = 1.05;
  double size = 50;
  String direction = "right";
  bool run = false;
  bool midJump = false;
  bool gameActive = false;
  Timer? gameTimer;
  Timer? jumpTimer;
  int remainingSeconds = 60;
  Random random = Random();
  int mushroomCount = 0;
  int highScore = 0;
  DateTime date = DateTime.now();

  var gameFont = GoogleFonts.pressStart2p(
    textStyle:const TextStyle(color: Colors.white, fontSize: 20),
  );

  fetchData() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection(COLLECTION_NAME).get();

      for (var doc in querySnapshot.docs) {
        // Update high score from Firestore
        var data = doc.data();
        if (data['highscore'] != null) {
          setState(() {
            highScore = data['highscore'] as int;
            // Parse the date if it's stored as a string
            if (data['date'] != null) {
              date = (data['date'] as Timestamp).toDate();
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  addData(int updatedScore) async {
    try {
      await FirebaseFirestore.instance
          .collection('SuperMaio')
          .doc("NVWeZeDiyyFaCpUYYXRE")
          .set({
        'highscore': updatedScore,
        'date': Timestamp.fromDate(DateTime.now()),
      });
      print(' Score saved successfully: $updatedScore');
    } catch (e) {
      print(' Error saving score: $e');
    }
  }

  void resetHeight() {
    time = 0;
    initHeight = marioY;
  }

  void startGame() {
    if (!gameActive) {
      setState(() {
        gameActive = true;
        remainingSeconds = 60;
        mushroomCount = 0;
        size = 50;
        marioX = 0;
        marioY = 1.05;
        midJump = false;
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
      fetchData();
    } catch (e) {
      print('Error reading saved progress: $e');
    }
  }

  void endGame() {
    gameTimer?.cancel();
    jumpTimer?.cancel();
    setState(() {
      gameActive = false;
      midJump = false;

      // Always save the score when game ends if it's higher
      if (mushroomCount >= highScore) {
        highScore = mushroomCount;
        date = DateTime.now();
        addData(highScore);
      }
    });
  }

  void ateMushroom() {
    if ((marioX - mushroomX).abs() < 0.15 &&
        (marioY - mushroomY).abs() < 0.25) {
      setState(() {
        mushroomX = random.nextDouble() * 2 - 1;
        mushroomY = 1 - random.nextDouble() * 0.3;
        if (size <= 200) {
          size += 10;
        }
        mushroomCount++;
      });
    }
  }

  void jump() {
    if (midJump == false && gameActive) {
      midJump = true;

      resetHeight();
      jumpTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;

        if (initHeight - height > 1.05) {
          midJump = false;
          setState(() {
            marioY = 1.05;
            timer.cancel();
          });
        } else {
          setState(() {
            marioY = initHeight - height;
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
    jumpTimer?.cancel();
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
            // flex: 1,
            child: Container(
              color: Colors.brown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!gameActive)
                    ElevatedButton(
                      onPressed: startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text('Start Game',
                          style: gameFont.copyWith(fontSize: 14)),
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
