import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';


String getAgendaTime(String startDatetime, String endDatetime) {
   var start = new DateFormat.jm().format(DateTime.parse(startDatetime)).toString();
   var end = new DateFormat.jm().format(DateTime.parse(endDatetime)).toString();
    return start + " - " + end;
  }


String getPostTime(String date){
   String msg = '';
   DateTime durs;
  var dt = DateTime.parse(date);
  if(dt.year == DateTime.now().year && dt.month == DateTime.now().month && dt.day == DateTime.now().day){
     durs = DateTime.now().subtract(Duration(hours: dt.hour,minutes: dt.minute,seconds: dt.second));
    
     if(durs.hour > 0){
       return '${durs.hour} h ago';
     }
     if(durs.minute > 0){
       return '${durs.minute} min ago';
     }
     else if(durs.second > 2){
      return '${durs.second} sec ago';
     }
     else{
       return 'just now';
     }
  }
  else{
     durs = DateTime.now().subtract(Duration(days: dt.day, hours: dt.hour,minutes: dt.minute,seconds: dt.second));
    
    if(durs.day >= 1){
      return durs.day == 1 ? 'Yesterday' :  DateFormat("dd MMM").format(dt);
    }
  }
 }



String getPostTime2(String date){
  if(date == null || date.isEmpty){
    return '';
  }
  var dt = DateTime.parse(date);
  var dat = DateFormat.jm().format(dt) + ' - ' + DateFormat("dd MMM yy").format(dt);
  return dat;
   
}
String getdob(String date){
  if(date == null || date.isEmpty){
    return '';
  }
  var dt = DateTime.parse(date);
  var dat = DateFormat.yMMMd().format(dt) ;
  return dat;
   
}
String getJoiningDate(String date){
  if(date == null || date.isEmpty){
    return '';
  }
  var dt = DateTime.parse(date);
  var dat = DateFormat("MMMM yyyy").format(dt) ;
  return  'Joined $dat';
   
}
String getChatTime(String date){
  if(date == null || date.isEmpty){
    return '';
  }
   String msg = '';
  var dt = DateTime.parse(date);
  
  if(DateTime.now().isBefore(dt)){
    return   DateFormat.jm().format(DateTime.parse(date)).toString();
   }
   

  var dur = DateTime.now().difference(dt);
  if(dur.inDays > 0){
    msg = '${dur.inDays} d';
    return dur.inDays == 1 ? 'yesterday' : DateFormat("dd MMM").format(dt);
  }
  else if(dur.inHours > 0){
     msg = '${dur.inHours} h';
  }
  else if(dur.inMinutes > 0){
     msg = '${dur.inMinutes} m'; 
  }
  else if(dur.inSeconds > 0){
     msg = '${dur.inSeconds} s';
  }else{
    msg = 'now';
  }
  return msg ;
}
String getPollTime(String date){
   int hr,mm;
   String msg = 'Poll ended';
   var enddate = DateTime.parse(date);
   if(DateTime.now().isAfter(enddate)){
     return msg;
   }
   msg = 'Poll ended in';
   var dur = enddate.difference(DateTime.now());
   hr = dur.inHours -  dur.inDays * 24;
   mm = dur.inMinutes -  (dur.inHours * 60);
   if(dur.inDays > 0 ){
     msg = ' ' +dur.inDays.toString() + (dur.inDays > 1 ? ' Days ' : ' Day');
   }
   if(hr > 0){
     msg += ' ' + hr.toString() + ' hour';
   }
   if(mm > 0){
     msg += ' ' + mm.toString() + ' min';
   }
  return (dur.inDays).toString()+ ' Days ' + ' ' + hr.toString() + ' Hours ' + mm.toString() + ' min';
}

 String getSocialLinks(String url ){
  
  if (url != null && url.isNotEmpty)
  {
      url = url.contains("https://www") || url.contains("http://www") ? url 
          : url.contains("www") && (!url.contains('https') && !url.contains('http')) ? 'https://' + url
          : 'https://www.' + url;
      
  }
  else{
    return null;
  }
  cprint('Launching URL : $url');
  return url;
}

launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      cprint('Could not launch $url');
    }
  }






void cprint(dynamic data,{String errorIn}){
  if(errorIn != null){
    print('****************************** error ******************************');
    print('[Error] $errorIn $data');
    print('****************************** error ******************************');
  }
  else{
    print(data);
  }
  
}

void share(String message,{String subject}) {
   Share.share(message,subject:subject);
}

List<String> getHashTags(String text) {
    RegExp reg = RegExp(
        r"([#])\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    List<String> resultMatches =List<String>();
    for (Match match in _matches) {
      if (match.group(0).isNotEmpty) {
       var tag  = match.group(0);
        resultMatches.add(tag);
      }
    }
    return resultMatches;
}

String getUserName({String name,String id}){
  String userName = '';
  name = name.split(' ')[0];
  id = id.substring(0,4);
  userName = '@$name$id';
  return userName.toLowerCase();
}

 
