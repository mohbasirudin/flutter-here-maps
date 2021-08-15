import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuPlace extends StatelessWidget {
  final List<String> places;
  final int curIndex;
  final Function(List<String>) funcTap;

  MenuPlace({
    required this.places,
    required this.curIndex,
    required this.funcTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 56,
            child: Center(
              child: Text(
                "Destination",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey.shade300,
            height: 2,
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                List<String> _data = places[index].split("&&");
                var _nama = _data[0];
                var _alamat = _data[3];
                var _image = _data[4];
                bool _selected = curIndex == index;
                return GestureDetector(
                  child: Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          margin: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(_image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _nama,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                _alamat,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Icon(
                            Icons.check_circle,
                            color:
                                _selected ? Colors.blue : Colors.grey.shade300,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _data.add(index.toString());
                    funcTap(_data);
                    Get.back();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
