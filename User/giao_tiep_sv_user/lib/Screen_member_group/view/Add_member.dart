import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/groups_members.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customMember.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupID;
  const AddMemberScreen({super.key, required this.groupID});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  //khai bao serivce
  final groupService = GroupserviceManeger();
  final userDB = Userservices();
  bool isload = false;
  
  List<Users> Listsearch = [];
  List<Users> ListMember = [];
  List<String> ListID= [];
  //danh sach duoc chon
  List<String> listSelected =[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Thêm thành viên",
          style: TextStyle(
            color: Color(0xffA72E2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Image.asset(
              "assets/icons/ic_back.png",
              fit: BoxFit.contain,
              height: 15,
              width: 15,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //search member
            Customsearch(
              onTap: (value) {
                setState(() {
                  bool checkSearchMail = value.contains("@mail.tdc.edu.vn");
                  if (checkSearchMail == true) {
                    Listsearch = ListMember.where((element) {
                      // print("e: ${element.email}");
                      return element.email.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                    print(Listsearch.length);
                  } else {
                    Listsearch = ListMember.where((element) {
                      return element.fullname.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  }
                });
              },
            ),
            SizedBox(height: 10),
            Text(
              "Kết quả:${Listsearch.length}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: create_listMember(),)
          ],
        ),
      ),

      

      //nut them xac nhan
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await addMemberGroup(listSelected);
          ScaffoldMessenger.of(context).showSnackBar(
            await SnackBar(
              content: Text('Đã thêm ${listSelected.length} thành viên vào nhóm , vui long doi duyet!'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  //them cac thanh vien duoc moi vao nhom
      Future<void> addMemberGroup(List<String> listUSAdd) async{
        for(var item in listUSAdd){
          var newValue = Groupmember(group_id: widget.groupID, user_id: item, role: 0, status_id: 0, joined_at: DateTime.now());
          print("role  ${newValue.role}");
          await groupService.addDataGroupMember(newValue);
        }
      }


//list user
  Widget create_listMember() {
    return (isload)?Center(child: CircularProgressIndicator(color: Colors.blue,),)
    :ListView.builder(
      shrinkWrap: true,
     // physics: NeverScrollableScrollPhysics(),
      itemCount: Listsearch.length,
      itemBuilder: (context, index) {
        var value = Listsearch[index];
        return CustommemberWidget(
          id: value.id_user,
          url: value.url_avt,
          fullname: value.fullname,
          ontap: (value) {
            print("${value!.idUser} - ${value!.picked}");
            if(value.picked==true){
              listSelected.add(value.idUser);
            }
            else{
              listSelected.removeWhere((element) {
                return element.trim().contains(value.idUser);
              },);
            }
          },
        );
      },
    );
  }

  Future<void> loadUsers()async{
    isload = true;
     userDB.streamBuilder().listen((event) {
      //even la toan bo danh sách nguoi dùng app 
      //widget.listMemberGroup danh sách cac nguoi dung bên trong nhom x 
      print("x: ${widget.groupID}");
      
      List<Users> listTemp =[];
      for(var item in event){
        var check = false;
        for(var x in ListMember){
          if(item.id_user.toLowerCase().trim().contains(x!.id_user.trim().toLowerCase())){
            check = true;
            break;
          }
        }
        if(check==false){
          listTemp.add(item);
        }
        check = false;
      }
      setState(() {
        ListMember = listTemp;
        Listsearch = listTemp;
        isload =false;
        
      });
    },);
  }

  Future<void> getAllMemberforGroup(String id) async{
    isload = true;
      ListID =await groupService.streamGetAllmember(id).first; 

    //  print("lengmember: ${}")

    for(var i in ListID){
      Users? user = await userDB.getUserForID(i);
      if(user!=null){
        ListMember.add(user);
      }
    }
    setState(() {
      isload=false;
    });
  }
  
  Future<void> initData() async{
    await getAllMemberforGroup(widget.groupID);
    await loadUsers();
  }
}
