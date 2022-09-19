import 'package:get/get.dart';

class getxcontroller extends GetxController {
  RxInt height = 0.obs;

  double cal_width(var json,double screen_width){
    if(json==null){return 0;}
    int line_num='\n'.allMatches(json.toString()).length;
    int i=0;
    int j=0;
    int k=0;
    var insert_list=List.generate(line_num, (_) => []);
    var attributes_list=List.generate(line_num, (_) => []);
    var size_list=List.generate(line_num, (_) => []);

    while(i<json.length){
      if(json[i]['insert'].contains('\n')){
        if(json[i]['insert']=='\n'&&json[i]['attributes']!=null){
          for(var t=0; t<attributes_list[j].length;t++){
            if(attributes_list[j][t]=='none')
            {attributes_list[j].removeAt(t);
            attributes_list[j].insert(t,json[i]['attributes']);
            }
          }j++;
        }else if(json[i]['insert'].startsWith('\n')&&json[i]['insert'].endsWith('\n')&&json[i]['attributes']==null){
          for(var p=0; p<json[i]['insert'].split('\n').length-1;p++){
            //insert_list[j].add('');
            insert_list[j].add((json[i]['insert'].split('\n'))[p]);   //  이 부분은 아래쪽과 중복의여지가있음&
            attributes_list[j].add('none');                             //  \n aaa \n 같은경우 제일처음의 ''를 없애는것도 좋아보임
            j++;}                                                       //  그럴려면 p=0이아닌 1로하는대신 다른조건을 추가해줘야할듯
        }else{
          k = (json[i]['insert'].endsWith('\n'))?json[i]['insert'].split('\n').length-1:json[i]['insert'].split('\n').length;
          for(int t=0; t<k; t++){
            insert_list[j].add(json[i]['insert'].split('\n')[t]);
            attributes_list[j].add('none');
            if(t!=k-1){j++;}
          }
        }
      }
      else{
        insert_list[j].add(json[i]['insert']);
        if(json[i]['attributes']!=null)
        {attributes_list[j].add(json[i]['attributes']);
        }else{attributes_list[j].add('none');}
      }
      i++;
    }

    // print('---------------------------------list출력');
    // if(insert_list.length !=null){
    //   for(var a=0; a<insert_list.length;a++){
    //     if(insert_list[a].length !=null){
    //       for(var b=0; b<insert_list[a].length;b++)
    //       {print(insert_list[a][b]);
    //       print(attributes_list[a][b]);}}
    //     print('---------------------------------nextline');
    //   }}


    if(attributes_list.length !=null){
      for(var a=0; a<insert_list.length;a++){
        if(attributes_list[a].length !=null){
          for(var b=0; b<insert_list[a].length;b++)
          {
            if(attributes_list[a][b].toString()=='none'){size_list[a].add(1);}
            else if(attributes_list[a][b].toString()=='{size: small}'){size_list[a].add(0.62);}
            else if(attributes_list[a][b].toString()=='{size: large}'){size_list[a].add(1.16);}
            else if(attributes_list[a][b].toString()=='{size: huge}'){size_list[a].add(1.38);}
            else if(attributes_list[a][b].toString()=='{header: 1}'){size_list[a].add(2.2);}
            else if(attributes_list[a][b].toString()=='{header: 2}'){size_list[a].add(1.5);}
            else if(attributes_list[a][b].toString()=='{header: 3}'){size_list[a].add(1.25);}
            else{size_list[a].add(1);}
          }}
      }}
    // print('---------------------------------list출력');
    // if(insert_list.length !=null){
    //   for(var a=0; a<insert_list.length;a++){
    //     if(insert_list[a].length !=null){
    //       for(var b=0; b<insert_list[a].length;b++)
    //       {print(insert_list[a][b]);
    //       print('${size_list[a][b]}');}}
    //     print('---------------------------------nextline');
    //   }}
    double total_size=0;
    if(size_list.length !=null){
      for(var a=0; a<insert_list.length;a++){
        if(size_list[a].length !=null){
          total_size += size_list[a].reduce((curr, next) => curr > next? curr: next);}
      }}

    double line_width=0;
    List<double> line_width_list=[];
    double toal_width=0;
    if(size_list.length !=null){
      for(var a=0; a<insert_list.length;a++){
        if(size_list[a].length !=null){
          line_width=0;
          for(var b=0; b<insert_list[a].length;b++){
            line_width += size_list[a][b] * insert_list[a][b].toString().length;
          }
          line_width_list.add(line_width);
        }
      }}
    double n = screen_width/9;
    for(var a=0; a<line_width_list.length;a++){
      for(var b=1;b<6;b++) {
        if(line_width_list[a]>b*n){
          toal_width+=size_list[a].reduce((curr, next) => curr > next? curr: next);
        }
      }
    }


    return total_size+toal_width;
  }
}