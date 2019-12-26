import 'dart:math';

import 'package:flutter/material.dart';

import '../customWidgets.dart';

class EmptyListWidget extends StatefulWidget{
  EmptyListWidget(this.title,{this.subTitle,this.image});

  final String image ;
  final String subTitle;
  final String title;

  @override
  State<StatefulWidget> createState() => _EmptyListWidgetState();
}
class _EmptyListWidgetState extends State<EmptyListWidget> with TickerProviderStateMixin{
  String title, subTitle,image = 'emptyImage.png';

   AnimationController   _backgroundController;
   AnimationController   _imageController;
   Animation _imageAnimation;
  //  Animation<RelativeRect> _rect =  RelativeRectTween(
  //   begin: new RelativeRect.fromLTRB(0.0, 0, 0.0, 0.0),
  //   end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
  // );
   @override
  void dispose() {
      _backgroundController.dispose();
      _imageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
     title = widget.title  ;
     subTitle = widget.subTitle;
     image = widget.image ??  'emptyImage.png';



     _backgroundController = AnimationController(duration: const Duration(minutes: 1),vsync: this,lowerBound: 0,upperBound: 20)..repeat();
     _imageController = AnimationController(duration: const Duration(seconds: 4),vsync: this,)..repeat();
    //  ..forward();
     
     _imageAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _imageController,curve: Curves.linear), );
   

    super.initState();
  }
  animationListner(){
    if(_imageController == null){
      return ;
    }
    if(_imageController.isCompleted){
      setState(() {
        _imageController.reverse();
      });
    }
    else{
      setState(() {
        _imageController.forward();
      });
    }
  }
  Widget _emptyListimage(){
    
   return  
   AnimatedBuilder(
     animation: _imageAnimation,
     builder: (BuildContext context,Widget child){
       return Transform.translate(
         offset: Offset(0, sin( _imageAnimation.value >.9 ? 1 -  _imageAnimation.value : _imageAnimation.value)),
         child: child
       );
     },
     child: Image.asset('assets/images/$image',height: getHeightDimention(context, 170)),
   );
   
  }
  Widget _imageBackground(){
    // print(fullHeight(context).toString());
     return 
     Container(
          width: getHeightDimention(context,fullWidth(context) * .95),
          height: getHeightDimention(context,fullWidth(context) * .95),
          decoration: BoxDecoration(
            // color: Color(0xfff1f3f6),
            boxShadow: <BoxShadow>[
              // BoxShadow(blurRadius: 50,offset: Offset(0, 0),color: Color(0xffe2e5ed),spreadRadius:20),
              BoxShadow(offset: Offset(0, 0),color:Color(0xffe2e5ed),),
              BoxShadow(blurRadius:30,offset: Offset(20,0),color: Color(0xffffffff),spreadRadius:-5),
            ],
            shape: BoxShape.circle
          ),
        );  
  }
  Widget _bubbles(){
      Animation<RelativeRect> rectAnimation = new RelativeRectTween(
    begin: new RelativeRect.fromLTRB((_imageAnimation.value), 20, 0.0, 0.0),
    end: new RelativeRect.fromLTRB(0.0, 0.0, (_imageAnimation.value), 20),
  ).animate(_backgroundController);
    return PositionedTransition(
      rect: rectAnimation,
    
    //  bottom: (_backgroundController.value),
    //  left: (_backgroundController.value),
    //   height:20,width: 20,
    //   duration: Duration(milliseconds: 500),
      child: Container(
        alignment: Alignment.bottomRight,
         child: Container(
            height: 50,
            width: 50,
             decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle
             ),
         ),
      ),
    );
  }
  double getHeightDimention(BuildContext context,double unit){
   if(fullHeight(context) <= 460.0){
    return unit / 1.5;
  }
  else {
    return getDimention(context, unit);
  }
  }
  @override
  Widget build(BuildContext context) {
   return   Container(
     color: Color(0xfffafafa),
       child:Center(
         child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // _bubbles(),
            // _wava(),
            RotationTransition(
              child: _imageBackground(),
             
              turns: _backgroundController,
            ),
           Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
              _emptyListimage(),
               SizedBox(height: 20,),
               customText(title,style: Theme.of(context).typography.dense.display1.copyWith(color: Color(0xff9da9c7)),context:context),
               customText(subTitle,style: Theme.of(context).typography.dense.body2.copyWith(color: Color(0xffabb8d6)),context:context),
           ],) ,
           
        ],)
       )
    );
  }
}

