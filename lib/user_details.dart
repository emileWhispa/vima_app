import 'package:cached_network_image/cached_network_image.dart';
import 'package:vima_app/cart_screen.dart';
import 'address_detail_screen.dart';
import 'order_history_screen.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'change_password_screen.dart';
import 'json/user.dart';

class UserDetails extends StatefulWidget{
  final User user;
  const UserDetails({Key? key, required this.user}) : super(key: key);

  @override
  Superbase<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends Superbase<UserDetails> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15).copyWith(
          top: MediaQuery.of(context).padding.top + 10
      ),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 26,backgroundImage: (widget.user.profile != null ? CachedNetworkImageProvider(widget.user.profile!) : const AssetImage("assets/boys.jpg") as ImageProvider)),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,children: [
                Text(widget.user.username ?? "---",style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 2,),
                Text(widget.user.email ?? "---",style: Theme.of(context).textTheme.titleMedium,),
              ],),
            )),
            // SizedBox(
            //   height: 30,
            //   width: 30,
            //   child: FloatingActionButton(
            //     onPressed: (){
            //       push(const EditProfileScreen());
            //     },
            //     elevation: 0.0,
            //     heroTag: "Hero-tag",
            //     backgroundColor: Colors.white24,
            //     child: const Icon(Icons.edit,size: 16,),
            //   ),
            // )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text("My Orders",style: Theme.of(context).textTheme.headlineMedium,),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 35,top: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: (){
                      push(const OrderHistoryScreen(status: "Pending",));
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/unpaid.png",
                            height: 21, width: 21),
                        const SizedBox(height: 2.4),
                        const Text("Unpaid"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      push(const OrderHistoryScreen(status: "Successfull",));
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/purchased.png",
                            height: 21, width: 21),
                        const SizedBox(height: 2.4),
                        const Text("Purchased"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      push(const OrderHistoryScreen(status: "Arrived",));
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/arrived.png",
                            height: 21, width: 21),
                        const SizedBox(height: 2.4),
                        const Text("Arrived"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      push(const OrderHistoryScreen(status: "Finished",));
                    },
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/finished.png",
                            height: 21, width: 21),
                        const SizedBox(height: 2.4),
                        const Text("Finished"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: (){
                      push(const AddressDetailScreen());
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_pin,color: Colors.blue.shade700,),
                        Expanded(child: Container(decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300
                                )
                            )
                        ),margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                            vertical: 12
                        ),child: Text("Shipping Address",style: Theme.of(context).textTheme.titleMedium,)))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: (){
                      push(const OrderHistoryScreen());
                    },
                    child: Row(
                      children: [
                        Icon(Icons.list,color: Colors.blue.shade700,),
                        Expanded(child: Container(decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300
                                )
                            )
                        ),margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                            vertical: 12
                        ),child: Text("Order History",style: Theme.of(context).textTheme.titleMedium,)))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: ()async{
                      const url = "https://e-gura.rw/zion/public/privacy/policy";
                      if(await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.security,color: Colors.blue.shade700,),
                        Expanded(child: Container(decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300
                                )
                            )
                        ),margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                            vertical: 12
                        ),child: Text("Privacy & Policy",style: Theme.of(context).textTheme.titleMedium,)))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: ()async{
                      push(const CartScreen());
                    },
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart,color: Colors.blue.shade700,),
                        Expanded(child: Container(margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                            vertical: 12
                        ),child: Text("Shopping Cart",style: Theme.of(context).textTheme.titleMedium,)))
                      ],
                    ),
                  ),
                ),
                User.user?.providerId == "password" ? Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: InkWell(
                    onTap: (){
                      push(const ChangePasswordScreen());
                    },
                    child: Row(
                      children: [
                        Icon(Icons.security,color: Colors.red.shade700,),
                        Expanded(child: Container(decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.transparent
                                )
                            )
                        ),margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                            vertical: 12
                        ),child: Text("Change Password",style: Theme.of(context).textTheme.titleMedium,)))
                      ],
                    ),
                  ),
                ) : const SizedBox.shrink(),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 0),
                //   child: InkWell(
                //     onTap: (){
                //
                //     },
                //     child: Row(
                //       children: [
                //         Icon(Icons.info,color: Colors.red.shade700,),
                //         Expanded(child: Container(decoration: const BoxDecoration(
                //             border: Border(
                //                 bottom: BorderSide(
                //                     color: Colors.transparent
                //                 )
                //             )
                //         ),margin: const EdgeInsets.only(left: 12),padding: const EdgeInsets.symmetric(
                //             vertical: 12
                //         ),child: Text("Version (3.2.1)",style: Theme.of(context).textTheme.subtitle1,)))
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        Align(child: TextButton(onPressed: (){
          showDialog(context: context, builder: (context){
            return  AlertDialog(
              title: const Text("Sign Out"),
              content: const Text("Are you sure you want to sign out ?"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: const Text("CANCEL")),
                TextButton(onPressed: ()async{
                  Navigator.pop(context);
                  await officialSignOut();
                }, child: const Text("OK")),
              ],
            );
          });
        }, child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_open),
            Text("Sign Out"),
          ],
        )))
      ],
    );
  }
}