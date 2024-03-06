import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard(
      {super.key, required this.colour, this.cardChild, required this.onPress});
  final Color colour;
  final Widget? cardChild;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 20,
          ),
        ],
        // gradient: Gradient.lerp(
        //   const LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [Colors.white, Colors.grey],
        //   ),
        //   const LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [Colors.grey, Colors.grey],
        //     stops: [0.5, 0.5],
        //   ),
        //   0.5,
        // ),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(colour),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onPressed: onPress,
        child: cardChild,
      ),
    );
  }
}
