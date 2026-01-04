import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mega_pro/global/app_colors.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  
  const AddEmployeeScreen({
    super.key, 
    required this.employeeData
  });

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Core employee data fields
  final TextEditingController empName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController position = TextEditingController();
  final TextEditingController salary = TextEditingController();
  
  // Dropdown fields
  String status = 'Active';
  String role = 'Employee'; // Default to Employee
  String? selectedDistrict;
  String? selectedBranch;
  
  // Date field
  DateTime joiningDate = DateTime.now();
  
  bool loading = false;
  bool isEditing = false;

  // District and Taluka data
  final Map<String, List<String>> _districtTalukaData = {
    "Ahmednagar": [
      "Ahmednagar", "Akole", "Jamkhed", "Karjat", "Kopargaon",
      "Nagar", "Nevasa", "Parner", "Pathardi", "Rahata",
      "Rahuri", "Sangamner", "Shrigonda", "Shrirampur"
    ],
    "Akola": [
      "Akola", "Balapur", "Barshitakli", "Murtizapur", "Telhara", "Akot"
    ],
    "Amravati": [
      "Amravati", "Anjangaon", "Chandur Bazar", "Chandur Railway",
      "Daryapur", "Dharni", "Morshi", "Nandgaon Khandeshwar",
      "Achalpur", "Warud"
    ],
    "Aurangabad": [
      "Aurangabad City", "Aurangabad Rural", "Kannad", "Khultabad",
      "Sillod", "Paithan", "Gangapur", "Vaijapur"
    ],
    "Beed": [
      "Beed", "Ashti", "Kaij", "Georai", "Majalgaon", "Parli",
      "Ambajogai", "Shirur", "Wadwani"
    ],
    "Bhandara": [
      "Bhandara", "Tumsar", "Sakoli", "Mohadi", "Pauni"
    ],
    "Buldhana": [
      "Buldhana", "Chikhli", "Deulgaon Raja", "Khamgaon", "Mehkar",
      "Nandura", "Malkapur", "Jalgaon Jamod", "Sindkhed Raja"
    ],
    "Chandrapur": [
      "Chandrapur", "Ballarpur", "Bhadravati", "Chimur", "Nagbhid",
      "Rajura", "Warora"
    ],
    "Dhule": [
      "Dhule", "Shirpur", "Sakri", "Sindkheda", "Dondaicha"
    ],
    "Gadchiroli": [
      "Gadchiroli", "Aheri", "Chamorshi", "Etapalli", "Rajura", "Armori"
    ],
    "Gondiya": [
      "Gondiya", "Amgaon", "Deori", "Salekasa", "Tirora"
    ],
    "Hingoli": [
      "Hingoli", "Kalamnuri", "Basmath", "Sengaon"
    ],
    "Jalgaon": [
      "Jalgaon", "Amalner", "Chopda", "Dharangaon", "Erandol",
      "Pachora", "Parola", "Bhusawal", "Raver"
    ],
    "Jalna": [
      "Jalna", "Bhokardan", "Badnapur", "Partur", "Ghansawangi", "Ambad"
    ],
    "Kolhapur": [
      "Kolhapur", "Hatkanangale", "Radhanagari", "Karvir", "Chandgad",
      "Shirol", "Panhala", "Gadhinglaj"
    ],
    "Latur": [
      "Latur", "Ausa", "Ahmedpur", "Udgir", "Nilanga", "Renapur", "Chakur"
    ],
    "Mumbai City": [
      "Mumbai City"
    ],
    "Mumbai Suburban": [
      "Andheri", "Borivali", "Kurla", "Mulund", "Bandra"
    ],
    "Nagpur": [
      "Nagpur", "Hingna", "Parseoni", "Kalmeshwar", "Umred", "Kuhi", "Savner"
    ],
    "Nanded": [
      "Nanded", "Deglur", "Biloli", "Bhokar", "Mukhed", "Loha", "Ardhapur", "Umri"
    ],
    "Nandurbar": [
      "Nandurbar", "Nawapur", "Shahada", "Taloda", "Akkalkuwa"
    ],
    "Nashik": [
      "Nashik", "Dindori", "Igatpuri", "Niphad", "Sinnar", "Yeola",
      "Trimbakeshwar", "Baglan", "Chandwad"
    ],
    "Osmanabad": [
      "Osmanabad", "Tuljapur", "Paranda", "Lohara", "Ausa", "Kalamb"
    ],
    "Palghar": [
      "Palghar", "Dahanu", "Talasari", "Umbergaon", "Vikramgad", "Jawhar", "Mokhada"
    ],
    "Parbhani": [
      "Parbhani", "Gangakhed", "Purna", "Selu", "Pathri"
    ],
    "Pune": [
      "Pune", "Haveli", "Maval", "Mulshi", "Khed (Ravet)", "Baramati",
      "Daund", "Indapur", "Junnar", "Shirur", "Bhor"
    ],
    "Raigad": [
      "Alibag", "Karjat", "Khalapur", "Mahad", "Mangaon", "Mhasala", "Panvel", "Pen", "Roha"
    ],
    "Ratnagiri": [
      "Ratnagiri", "Chiplun", "Khed", "Guhagar", "Lanja", "Sangameshwar"
    ],
    "Sangli": [
      "Sangli", "Miraj", "Tasgaon", "Jat", "Kavathe Mahankal", "Palus"
    ],
    "Satara": [
      "Satara", "Karad", "Wai", "Khandala", "Patan", "Wai", "Phaltan", "Man"
    ],
    "Sindhudurg": [
      "Sindhudurg", "Kankavli", "Malvan", "Vengurla", "Sawantwadi"
    ],
    "Solapur": [
      "Solapur", "Akkalkot", "Barshi", "Mangalwedha", "Pandharpur", "Madha", "Karmala", "Sangola"
    ],
    "Thane": [
      "Thane", "Bhiwandi", "Kalyan", "Ulhasnagar", "Ambarnath", "Shahapur", "Murbad", "Wada", "Jawahar"
    ],
    "Wardha": [
      "Wardha", "Deoli", "Arvi"
    ],
    "Washim": [
      "Washim", "Mangrulpir", "Karanja"
    ],
    "Yavatmal": [
      "Yavatmal", "Umarkhed", "Darwha", "Pusad", "Ghatanji", "Kalamb"
    ],
  };

  List<String> get _districts => _districtTalukaData.keys.toList()..sort();
  List<String> get _talukas => selectedDistrict != null 
      ? _districtTalukaData[selectedDistrict!] ?? [] 
      : [];

  // Check if location fields should be shown
  bool get showLocationFields => role == 'Employee';
  bool get showDistrictField => role == 'Employee' || role == 'Marketing Manager' || role == 'Production Manager';
  bool get showBranchField => role == 'Employee';

  @override
  void initState() {
    super.initState();
    
    if (widget.employeeData.isNotEmpty && widget.employeeData.containsKey('id')) {
      isEditing = true;
      empName.text = widget.employeeData['full_name'] ?? '';
      email.text = widget.employeeData['email'] ?? '';
      phone.text = widget.employeeData['phone'] ?? '';
      position.text = widget.employeeData['position'] ?? '';
      selectedBranch = widget.employeeData['branch'] ?? '';
      selectedDistrict = widget.employeeData['district'] ?? '';
      salary.text = widget.employeeData['salary']?.toString() ?? '';
      status = widget.employeeData['status'] ?? 'Active';
      role = widget.employeeData['role'] ?? 'Employee';
      
      final joiningDateStr = widget.employeeData['joining_date'];
      if (joiningDateStr != null) {
        joiningDate = DateTime.parse(joiningDateStr);
      }
    }
  }

  String generateEmpId() {
    final year = DateTime.now().year;
    final randomNum = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10);
    return "CF$year-$randomNum";
  }

  Future<void> saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() => loading = true);
    
    print('=== SAVING EMPLOYEE DATA ===');
    print('Full Name: ${empName.text}');
    print('Email: ${email.text}');
    print('Phone: ${phone.text}');
    print('Position: ${position.text}');
    print('Role: $role');
    print('Status: $status');
    print('Branch: $selectedBranch');
    print('District: $selectedDistrict');
    print('Salary: ${salary.text}');
    print('Joining Date: ${joiningDate.toIso8601String()}');
    print('Is Editing: $isEditing');
    if (isEditing) {
      print('Employee ID: ${widget.employeeData['id']}');
    }

    try {
      final supabase = Supabase.instance.client;
      
      final employeeData = {
        'full_name': empName.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'position': position.text.trim(),
        'joining_date': joiningDate.toIso8601String(),
        'status': status,
        'role': role,
        'salary': int.tryParse(salary.text) ?? 0,
      };

      // Only include location fields if applicable
      if (showLocationFields || showDistrictField) {
        if (selectedDistrict != null) {
          employeeData['district'] = selectedDistrict!;
        }
        if (selectedBranch != null && showBranchField) {
          employeeData['branch'] = selectedBranch!;
        }
      }
      
      if (!isEditing) {
        employeeData['performance'] = 0.0;
        employeeData['attendance'] = 0.0;
      } else {
        employeeData['performance'] = widget.employeeData['performance'] ?? 0.0;
        employeeData['attendance'] = widget.employeeData['attendance'] ?? 0.0;
      }
      
      print('Employee Data to Save: $employeeData');

      if (isEditing) {
        print('Updating employee with ID: ${widget.employeeData['id']}');
        final response = await supabase
            .from('emp_profile')
            .update(employeeData)
            .eq('id', widget.employeeData['id'])
            .select();
        
        print('Update Response: $response');
        
        if (response.isNotEmpty) {
          print('Update successful!');
        }
      } else {
        final empId = generateEmpId();
        employeeData['emp_id'] = empId;
        
        print('Inserting new employee with EMP_ID: $empId');
        final response = await supabase
            .from('emp_profile')
            .insert(employeeData)
            .select();
        
        print('Insert Response: $response');
        
        if (response.isNotEmpty) {
          print('Insert successful!');
        }
      }

      if (!mounted) {
        print('Context not mounted, returning');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Employee updated successfully!' : 'Employee added successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      Navigator.pop(context);
      
    } catch (e, stackTrace) {
      print('=== ERROR SAVING EMPLOYEE ===');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // Improved Dropdown Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Employee" : "Add New Employee",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      color: AppColors.primaryBlue,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? "Edit Employee Details" : "Employee Registration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing 
                              ? "Update employee information as needed"
                              : "Fill in the essential employee details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Basic Information
                    _sectionTitle("Basic Information"),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: empName,
                      label: "Employee Name",
                      icon: Icons.person_outline,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: email,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: phone,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: position,
                      label: "Position/Designation",
                      icon: Icons.work_outline,
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Role & Status Section
                    _sectionTitle("Role & Status"),
                    const SizedBox(height: 12),
                    
                    // Role Dropdown - Minimal Professional UI
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            "Role *",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1.5,
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                value: role,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                                iconSize: 24,
                                elevation: 0,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Employee',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Employee',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Marketing Manager',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Marketing Manager',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Production Manager',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Production Manager',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Owner',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Owner',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      role = value;
                                      // Clear location fields when role changes
                                      if (value == 'Owner') {
                                        selectedDistrict = null;
                                        selectedBranch = null;
                                      } else if (value == 'Marketing Manager' || value == 'Production Manager') {
                                        selectedBranch = null;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1.5,
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                value: status,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey[600],
                                  size: 24,
                                ),
                                iconSize: 24,
                                elevation: 0,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                underline: const SizedBox(),
                                items: const [
                                  'Active',
                                  'On Leave',
                                  'Probation',
                                  'Terminated',
                                  'Resigned',
                                ].map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        status,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => status = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Joining Date
                    _buildDateField(
                      date: joiningDate,
                      label: "Joining Date",
                      onDateSelected: (date) {
                        setState(() => joiningDate = date);
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Location & Salary - Conditionally shown
                    if (showLocationFields || showDistrictField) ...[
                      _sectionTitle("Location & Compensation"),
                      const SizedBox(height: 12),
                      
                      // District Dropdown (shown for Employee, Marketing Manager, Production Manager)
                      if (showDistrictField) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                "District ${role == 'Employee' ? '*' : ''}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: selectedDistrict,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 24,
                                    ),
                                    iconSize: 24,
                                    elevation: 0,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Select District",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    underline: const SizedBox(),
                                    items: _districts.map((district) {
                                      return DropdownMenuItem<String>(
                                        value: district,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text(
                                            district,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedDistrict = value;
                                          selectedBranch = null; // Clear branch when district changes
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (role == 'Employee')
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  '* Required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                      
                      // Branch/Taluka Dropdown (shown only for Employee)
                      if (showBranchField) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                "Branch/Taluka *",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: selectedBranch,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 24,
                                    ),
                                    iconSize: 24,
                                    elevation: 0,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        selectedDistrict != null 
                                            ? "Select Branch/Taluka" 
                                            : "Select District First",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    underline: const SizedBox(),
                                    items: _talukas.map((taluka) {
                                      return DropdownMenuItem<String>(
                                        value: taluka,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text(
                                            taluka,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedBranch = value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ],
                    
                    // Salary Field
                    _buildTextField(
                      controller: salary,
                      label: "Monthly Salary (₹)",
                      icon: Icons.currency_rupee_outlined,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      prefixText: "₹ ",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Salary is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // District-Taluka Info Card (shown only when applicable)
                    if (showLocationFields && selectedDistrict != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location: $selectedDistrict",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedBranch != null
                                        ? "Selected Branch: $selectedBranch"
                                        : "Select a branch/taluka from the ${_talukas.length} available options",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  if (_talukas.isNotEmpty && selectedBranch == null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "Available Branches: ${_talukas.take(3).join(', ')}${_talukas.length > 3 ? '...' : ''}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Role Information Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getRoleCardColor(),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRoleBorderColor(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(),
                            color: _getRoleColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Role: $role",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getRoleColor(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getRoleDescription(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: saveEmployee,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.update : Icons.check_circle_outline, 
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isEditing ? "UPDATE EMPLOYEE" : "SAVE EMPLOYEE",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for role styling
  Color _getRoleColor() {
    switch (role) {
      case 'Marketing Manager':
        return Colors.purple;
      case 'Production Manager':
        return Colors.orange;
      case 'Owner':
        return Colors.green;
      default:
        return AppColors.primaryBlue;
    }
  }

  Color _getRoleCardColor() {
    switch (role) {
      case 'Marketing Manager':
        return Colors.purple.withOpacity(0.05);
      case 'Production Manager':
        return Colors.orange.withOpacity(0.05);
      case 'Owner':
        return Colors.green.withOpacity(0.05);
      default:
        return AppColors.primaryBlue.withOpacity(0.05);
    }
  }

  Color _getRoleBorderColor() {
    switch (role) {
      case 'Marketing Manager':
        return Colors.purple.withOpacity(0.2);
      case 'Production Manager':
        return Colors.orange.withOpacity(0.2);
      case 'Owner':
        return Colors.green.withOpacity(0.2);
      default:
        return AppColors.primaryBlue.withOpacity(0.1);
    }
  }

  IconData _getRoleIcon() {
    switch (role) {
      case 'Marketing Manager':
        return Icons.campaign_outlined;
      case 'Production Manager':
        return Icons.factory_outlined;
      case 'Owner':
        return Icons.verified_user_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _getRoleDescription() {
    switch (role) {
      case 'Marketing Manager':
        return "Will access Marketing Manager Dashboard with sales and marketing features";
      case 'Production Manager':
        return "Will access Production Manager Dashboard with inventory and production tools";
      case 'Owner':
        return "Will access Owner Dashboard with full administrative privileges";
      default:
        return "Will access Employee Dashboard with basic work features";
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            isRequired ? "$label *" : label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              prefixIcon: Icon(
                icon, 
                color: AppColors.primaryBlue.withOpacity(0.7),
                size: 22,
              ),
              prefixText: prefixText,
              suffixText: suffixText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: validator ?? (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime date,
    required String label,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryBlue,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primaryBlue.withOpacity(0.7),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:mega_pro/global/app_colors.dart';

// class AddEmployeeScreen extends StatefulWidget {
//   final Map<String, dynamic> employeeData;
  
//   const AddEmployeeScreen({
//     super.key, 
//     required this.employeeData
//   });

//   @override
//   State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
// }

// class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Core employee data fields
//   final TextEditingController empName = TextEditingController();
//   final TextEditingController email = TextEditingController();
//   final TextEditingController phone = TextEditingController();
//   final TextEditingController position = TextEditingController();
//   final TextEditingController salary = TextEditingController();
  
//   // Dropdown fields - Use variables for dropdown values
//   String status = 'Active';
//   String role = 'Employee'; // Default to Employee
//   String? selectedDistrict;
//   String? selectedBranch;
  
//   // Date field
//   DateTime joiningDate = DateTime.now();
  
//   bool loading = false;
//   bool isEditing = false;

//   // District and Taluka data
//   final Map<String, List<String>> _districtTalukaData = {
//     "Ahmednagar": [
//       "Ahmednagar", "Akole", "Jamkhed", "Karjat", "Kopargaon",
//       "Nagar", "Nevasa", "Parner", "Pathardi", "Rahata",
//       "Rahuri", "Sangamner", "Shrigonda", "Shrirampur"
//     ],
//     "Akola": [
//       "Akola", "Balapur", "Barshitakli", "Murtizapur", "Telhara", "Akot"
//     ],
//     "Amravati": [
//       "Amravati", "Anjangaon", "Chandur Bazar", "Chandur Railway",
//       "Daryapur", "Dharni", "Morshi", "Nandgaon Khandeshwar",
//       "Achalpur", "Warud"
//     ],
//     "Aurangabad": [
//       "Aurangabad City", "Aurangabad Rural", "Kannad", "Khultabad",
//       "Sillod", "Paithan", "Gangapur", "Vaijapur"
//     ],
//     "Beed": [
//       "Beed", "Ashti", "Kaij", "Georai", "Majalgaon", "Parli",
//       "Ambajogai", "Shirur", "Wadwani"
//     ],
//     "Bhandara": [
//       "Bhandara", "Tumsar", "Sakoli", "Mohadi", "Pauni"
//     ],
//     "Buldhana": [
//       "Buldhana", "Chikhli", "Deulgaon Raja", "Khamgaon", "Mehkar",
//       "Nandura", "Malkapur", "Jalgaon Jamod", "Sindkhed Raja"
//     ],
//     "Chandrapur": [
//       "Chandrapur", "Ballarpur", "Bhadravati", "Chimur", "Nagbhid",
//       "Rajura", "Warora"
//     ],
//     "Dhule": [
//       "Dhule", "Shirpur", "Sakri", "Sindkheda", "Dondaicha"
//     ],
//     "Gadchiroli": [
//       "Gadchiroli", "Aheri", "Chamorshi", "Etapalli", "Rajura", "Armori"
//     ],
//     "Gondiya": [
//       "Gondiya", "Amgaon", "Deori", "Salekasa", "Tirora"
//     ],
//     "Hingoli": [
//       "Hingoli", "Kalamnuri", "Basmath", "Sengaon"
//     ],
//     "Jalgaon": [
//       "Jalgaon", "Amalner", "Chopda", "Dharangaon", "Erandol",
//       "Pachora", "Parola", "Bhusawal", "Raver"
//     ],
//     "Jalna": [
//       "Jalna", "Bhokardan", "Badnapur", "Partur", "Ghansawangi", "Ambad"
//     ],
//     "Kolhapur": [
//       "Kolhapur", "Hatkanangale", "Radhanagari", "Karvir", "Chandgad",
//       "Shirol", "Panhala", "Gadhinglaj"
//     ],
//     "Latur": [
//       "Latur", "Ausa", "Ahmedpur", "Udgir", "Nilanga", "Renapur", "Chakur"
//     ],
//     "Mumbai City": [
//       "Mumbai City"
//     ],
//     "Mumbai Suburban": [
//       "Andheri", "Borivali", "Kurla", "Mulund", "Bandra"
//     ],
//     "Nagpur": [
//       "Nagpur", "Hingna", "Parseoni", "Kalmeshwar", "Umred", "Kuhi", "Savner"
//     ],
//     "Nanded": [
//       "Nanded", "Deglur", "Biloli", "Bhokar", "Mukhed", "Loha", "Ardhapur", "Umri"
//     ],
//     "Nandurbar": [
//       "Nandurbar", "Nawapur", "Shahada", "Taloda", "Akkalkuwa"
//     ],
//     "Nashik": [
//       "Nashik", "Dindori", "Igatpuri", "Niphad", "Sinnar", "Yeola",
//       "Trimbakeshwar", "Baglan", "Chandwad"
//     ],
//     "Osmanabad": [
//       "Osmanabad", "Tuljapur", "Paranda", "Lohara", "Ausa", "Kalamb"
//     ],
//     "Palghar": [
//       "Palghar", "Dahanu", "Talasari", "Umbergaon", "Vikramgad", "Jawhar", "Mokhada"
//     ],
//     "Parbhani": [
//       "Parbhani", "Gangakhed", "Purna", "Selu", "Pathri"
//     ],
//     "Pune": [
//       "Pune", "Haveli", "Maval", "Mulshi", "Khed (Ravet)", "Baramati",
//       "Daund", "Indapur", "Junnar", "Shirur", "Bhor"
//     ],
//     "Raigad": [
//       "Alibag", "Karjat", "Khalapur", "Mahad", "Mangaon", "Mhasala", "Panvel", "Pen", "Roha"
//     ],
//     "Ratnagiri": [
//       "Ratnagiri", "Chiplun", "Khed", "Guhagar", "Lanja", "Sangameshwar"
//     ],
//     "Sangli": [
//       "Sangli", "Miraj", "Tasgaon", "Jat", "Kavathe Mahankal", "Palus"
//     ],
//     "Satara": [
//       "Satara", "Karad", "Wai", "Khandala", "Patan", "Wai", "Phaltan", "Man"
//     ],
//     "Sindhudurg": [
//       "Sindhudurg", "Kankavli", "Malvan", "Vengurla", "Sawantwadi"
//     ],
//     "Solapur": [
//       "Solapur", "Akkalkot", "Barshi", "Mangalwedha", "Pandharpur", "Madha", "Karmala", "Sangola"
//     ],
//     "Thane": [
//       "Thane", "Bhiwandi", "Kalyan", "Ulhasnagar", "Ambarnath", "Shahapur", "Murbad", "Wada", "Jawahar"
//     ],
//     "Wardha": [
//       "Wardha", "Deoli", "Arvi"
//     ],
//     "Washim": [
//       "Washim", "Mangrulpir", "Karanja"
//     ],
//     "Yavatmal": [
//       "Yavatmal", "Umarkhed", "Darwha", "Pusad", "Ghatanji", "Kalamb"
//     ],
//   };

//   List<String> get _districts => _districtTalukaData.keys.toList()..sort();
//   List<String> get _talukas => selectedDistrict != null 
//       ? _districtTalukaData[selectedDistrict!] ?? [] 
//       : [];

//   @override
//   void initState() {
//     super.initState();
    
//     if (widget.employeeData.isNotEmpty && widget.employeeData.containsKey('id')) {
//       isEditing = true;
//       empName.text = widget.employeeData['full_name'] ?? '';
//       email.text = widget.employeeData['email'] ?? '';
//       phone.text = widget.employeeData['phone'] ?? '';
//       position.text = widget.employeeData['position'] ?? '';
//       selectedBranch = widget.employeeData['branch'] ?? '';
//       selectedDistrict = widget.employeeData['district'] ?? '';
//       salary.text = widget.employeeData['salary']?.toString() ?? '';
//       status = widget.employeeData['status'] ?? 'Active';
//       role = widget.employeeData['role'] ?? 'Employee';
      
//       final joiningDateStr = widget.employeeData['joining_date'];
//       if (joiningDateStr != null) {
//         joiningDate = DateTime.parse(joiningDateStr);
//       }
//     }
//   }

//   String generateEmpId() {
//     final year = DateTime.now().year;
//     final randomNum = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10);
//     return "CF$year-$randomNum";
//   }

//   Future<void> saveEmployee() async {
//     if (!_formKey.currentState!.validate()) {
//       print('Form validation failed');
//       return;
//     }

//     setState(() => loading = true);
    
//     print('=== SAVING EMPLOYEE DATA ===');
//     print('Full Name: ${empName.text}');
//     print('Email: ${email.text}');
//     print('Phone: ${phone.text}');
//     print('Position: ${position.text}');
//     print('Role: $role');
//     print('Status: $status');
//     print('Branch: $selectedBranch');
//     print('District: $selectedDistrict');
//     print('Salary: ${salary.text}');
//     print('Joining Date: ${joiningDate.toIso8601String()}');
//     print('Is Editing: $isEditing');
//     if (isEditing) {
//       print('Employee ID: ${widget.employeeData['id']}');
//     }

//     try {
//       final supabase = Supabase.instance.client;
      
//       final employeeData = {
//         'full_name': empName.text.trim(),
//         'email': email.text.trim(),
//         'phone': phone.text.trim(),
//         'position': position.text.trim(),
//         'branch': selectedBranch ?? '',
//         'district': selectedDistrict ?? '',
//         'joining_date': joiningDate.toIso8601String(),
//         'status': status,
//         'role': role,
//         'salary': int.tryParse(salary.text) ?? 0,
//       };
      
//       if (!isEditing) {
//         employeeData['performance'] = 0.0;
//         employeeData['attendance'] = 0.0;
//       } else {
//         employeeData['performance'] = widget.employeeData['performance'] ?? 0.0;
//         employeeData['attendance'] = widget.employeeData['attendance'] ?? 0.0;
//       }
      
//       print('Employee Data to Save: $employeeData');

//       if (isEditing) {
//         print('Updating employee with ID: ${widget.employeeData['id']}');
//         final response = await supabase
//             .from('emp_profile')
//             .update(employeeData)
//             .eq('id', widget.employeeData['id'])
//             .select();
        
//         print('Update Response: $response');
        
//         if (response.isNotEmpty) {
//           print('Update successful!');
//         }
//       } else {
//         final empId = generateEmpId();
//         employeeData['emp_id'] = empId;
        
//         print('Inserting new employee with EMP_ID: $empId');
//         final response = await supabase
//             .from('emp_profile')
//             .insert(employeeData)
//             .select();
        
//         print('Insert Response: $response');
        
//         if (response.isNotEmpty) {
//           print('Insert successful!');
//         }
//       }

//       if (!mounted) {
//         print('Context not mounted, returning');
//         return;
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(isEditing ? 'Employee updated successfully!' : 'Employee added successfully!'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
      
//       await Future.delayed(const Duration(milliseconds: 1500));
      
//       Navigator.pop(context);
      
//     } catch (e, stackTrace) {
//       print('=== ERROR SAVING EMPLOYEE ===');
//       print('Error: $e');
//       print('Stack Trace: $stackTrace');
      
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           isEditing ? "Edit Employee" : "Add New Employee",
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppColors.primaryBlue.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.person_add_alt_1,
//                       color: AppColors.primaryBlue,
//                       size: 30,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             isEditing ? "Edit Employee Details" : "Employee Registration",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primaryBlue,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             isEditing 
//                               ? "Update employee information as needed"
//                               : "Fill in the essential employee details",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Basic Information
//                     _sectionTitle("Basic Information"),
//                     const SizedBox(height: 12),
                    
//                     _buildTextField(
//                       controller: empName,
//                       label: "Employee Name",
//                       icon: Icons.person_outline,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: email,
//                       label: "Email Address",
//                       icon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       isRequired: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Email is required';
//                         }
//                         if (!value.contains('@')) {
//                           return 'Enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: phone,
//                       label: "Phone Number",
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                       isRequired: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Phone number is required';
//                         }
//                         if (value.length < 10) {
//                           return 'Enter a valid phone number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: position,
//                       label: "Position/Designation",
//                       icon: Icons.work_outline,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Role & Status Section
//                     _sectionTitle("Role & Status"),
//                     const SizedBox(height: 12),
                    
//                     // Role Dropdown - Clean UI
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: role,
//                         decoration: InputDecoration(
//                           labelText: "Role *",
//                           hintText: "Select Role",
//                           prefixIcon: Icon(
//                             Icons.groups,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'Employee',
//                             child: Text('Employee'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Marketing Manager',
//                             child: Text('Marketing Manager'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Production Manager',
//                             child: Text('Production Manager'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Owner',
//                             child: Text('Owner'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() => role = value);
//                           }
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Role is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Status Dropdown
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: status,
//                         decoration: InputDecoration(
//                           labelText: "Status",
//                           hintText: "Select Status",
//                           prefixIcon: Icon(
//                             Icons.circle_outlined,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: const [
//                           'Active',
//                           'On Leave',
//                           'Probation',
//                           'Terminated',
//                           'Resigned',
//                         ].map((status) {
//                           return DropdownMenuItem<String>(
//                             value: status,
//                             child: Text(status),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() => status = value);
//                           }
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Joining Date
//                     _buildDateField(
//                       date: joiningDate,
//                       label: "Joining Date",
//                       onDateSelected: (date) {
//                         setState(() => joiningDate = date);
//                       },
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Location & Salary
//                     _sectionTitle("Location & Compensation"),
//                     const SizedBox(height: 12),
                    
//                     // District Dropdown
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: selectedDistrict,
//                         decoration: InputDecoration(
//                           labelText: "District *",
//                           hintText: "Select District",
//                           prefixIcon: Icon(
//                             Icons.map_outlined,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: _districts.map((district) {
//                           return DropdownMenuItem<String>(
//                             value: district,
//                             child: Text(district),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() {
//                               selectedDistrict = value;
//                               selectedBranch = null; // Clear branch when district changes
//                             });
//                           }
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'District is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Branch/Taluka Dropdown (depends on district)
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: selectedBranch,
//                         decoration: InputDecoration(
//                           labelText: "Branch/Taluka *",
//                           hintText: selectedDistrict != null ? "Select Branch/Taluka" : "Select District First",
//                           prefixIcon: Icon(
//                             Icons.location_on_outlined,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: _talukas.map((taluka) {
//                           return DropdownMenuItem<String>(
//                             value: taluka,
//                             child: Text(taluka),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() => selectedBranch = value);
//                           }
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Branch/Taluka is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: salary,
//                       label: "Monthly Salary (₹)",
//                       icon: Icons.currency_rupee_outlined,
//                       keyboardType: TextInputType.number,
//                       isRequired: true,
//                       prefixText: "₹ ",
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Salary is required';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'Enter valid amount';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),
                    
//                     // District-Taluka Info Card
//                     if (selectedDistrict != null) ...[
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Colors.blue.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: Colors.blue[700],
//                               size: 20,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Location: $selectedDistrict",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.blue[700],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     selectedBranch != null
//                                         ? "Selected Branch: $selectedBranch"
//                                         : "Select a branch/taluka from the ${_talukas.length} available options",
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: Colors.grey[700],
//                                     ),
//                                   ),
//                                   if (_talukas.isNotEmpty && selectedBranch == null) ...[
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       "Available Branches: ${_talukas.take(3).join(', ')}${_talukas.length > 3 ? '...' : ''}",
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: Colors.grey[600],
//                                         fontStyle: FontStyle.italic,
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
                    
//                     // Role Information Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: _getRoleCardColor(),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _getRoleBorderColor(),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _getRoleIcon(),
//                             color: _getRoleColor(),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Role: $role",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: _getRoleColor(),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _getRoleDescription(),
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 32),
                    
//                     // Submit Button
//                     loading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.primaryBlue,
//                             ),
//                           )
//                         : SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: saveEmployee,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.primaryBlue,
//                                 elevation: 2,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     isEditing ? Icons.update : Icons.check_circle_outline, 
//                                     color: Colors.white
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     isEditing ? "UPDATE EMPLOYEE" : "SAVE EMPLOYEE",
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods for role styling
//   Color _getRoleColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple;
//       case 'Production Manager':
//         return Colors.orange;
//       case 'Owner':
//         return Colors.green;
//       default:
//         return AppColors.primaryBlue;
//     }
//   }

//   Color _getRoleCardColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple.withOpacity(0.05);
//       case 'Production Manager':
//         return Colors.orange.withOpacity(0.05);
//       case 'Owner':
//         return Colors.green.withOpacity(0.05);
//       default:
//         return AppColors.primaryBlue.withOpacity(0.05);
//     }
//   }

//   Color _getRoleBorderColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple.withOpacity(0.2);
//       case 'Production Manager':
//         return Colors.orange.withOpacity(0.2);
//       case 'Owner':
//         return Colors.green.withOpacity(0.2);
//       default:
//         return AppColors.primaryBlue.withOpacity(0.1);
//     }
//   }

//   IconData _getRoleIcon() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Icons.campaign_outlined;
//       case 'Production Manager':
//         return Icons.factory_outlined;
//       case 'Owner':
//         return Icons.verified_user_outlined;
//       default:
//         return Icons.person_outline;
//     }
//   }

//   String _getRoleDescription() {
//     switch (role) {
//       case 'Marketing Manager':
//         return "Will access Marketing Manager Dashboard with sales and marketing features";
//       case 'Production Manager':
//         return "Will access Production Manager Dashboard with inventory and production tools";
//       case 'Owner':
//         return "Will access Owner Dashboard with full administrative privileges";
//       default:
//         return "Will access Employee Dashboard with basic work features";
//     }
//   }

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: AppColors.primaryBlue,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isRequired = false,
//     TextInputType? keyboardType,
//     String? prefixText,
//     String? suffixText,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: isRequired ? "$label *" : label,
//           hintText: "Enter $label",
//           prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.7)),
//           prefixText: prefixText,
//           suffixText: suffixText,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         ),
//         validator: validator ?? (value) {
//           if (isRequired && (value == null || value.isEmpty)) {
//             return '$label is required';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildDateField({
//     required DateTime date,
//     required String label,
//     required Function(DateTime) onDateSelected,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: GestureDetector(
//         onTap: () async {
//           final selectedDate = await showDatePicker(
//             context: context,
//             initialDate: date,
//             firstDate: DateTime(2000),
//             lastDate: DateTime.now(),
//             builder: (context, child) {
//               return Theme(
//                 data: Theme.of(context).copyWith(
//                   colorScheme: ColorScheme.light(
//                     primary: AppColors.primaryBlue,
//                     onPrimary: Colors.white,
//                     surface: Colors.white,
//                     onSurface: Colors.black,
//                   ),
//                   dialogBackgroundColor: Colors.white,
//                 ),
//                 child: child!,
//               );
//             },
//           );
//           if (selectedDate != null) {
//             onDateSelected(selectedDate);
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.borderGrey),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.calendar_today_outlined,
//                 color: AppColors.primaryBlue.withOpacity(0.7),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       DateFormat('dd MMM yyyy').format(date),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_drop_down,
//                 color: Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:mega_pro/global/app_colors.dart';

// class AddEmployeeScreen extends StatefulWidget {
//   final Map<String, dynamic> employeeData;
  
//   const AddEmployeeScreen({
//     super.key, 
//     required this.employeeData
//   });

//   @override
//   State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
// }

// class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Core employee data fields
//   final empName = TextEditingController();
//   final email = TextEditingController();
//   final phone = TextEditingController();
//   final position = TextEditingController();
//   final branch = TextEditingController();
//   final district = TextEditingController();
//   final salary = TextEditingController();
  
//   // Dropdown fields
//   String status = 'Active';
//   String role = 'Employee'; // Default to Employee
  
//   // Date field
//   DateTime joiningDate = DateTime.now();
  
//   bool loading = false;
//   bool isEditing = false;

//   @override
//   void initState() {
//     super.initState();
    
//     if (widget.employeeData.isNotEmpty && widget.employeeData.containsKey('id')) {
//       isEditing = true;
//       empName.text = widget.employeeData['full_name'] ?? '';
//       email.text = widget.employeeData['email'] ?? '';
//       phone.text = widget.employeeData['phone'] ?? '';
//       position.text = widget.employeeData['position'] ?? '';
//       branch.text = widget.employeeData['branch'] ?? '';
//       district.text = widget.employeeData['district'] ?? '';
//       salary.text = widget.employeeData['salary']?.toString() ?? '';
//       status = widget.employeeData['status'] ?? 'Active';
//       role = widget.employeeData['role'] ?? 'Employee';
      
//       final joiningDateStr = widget.employeeData['joining_date'];
//       if (joiningDateStr != null) {
//         joiningDate = DateTime.parse(joiningDateStr);
//       }
//     }
//   }

//   String generateEmpId() {
//     final year = DateTime.now().year;
//     final randomNum = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10);
//     return "CF$year-$randomNum";
//   }

//   Future<void> saveEmployee() async {
//   if (!_formKey.currentState!.validate()) {
//     print('Form validation failed');
//     return;
//   }

//   setState(() => loading = true);
  
//   print('=== SAVING EMPLOYEE DATA ===');
//   print('Full Name: ${empName.text}');
//   print('Email: ${email.text}');
//   print('Phone: ${phone.text}');
//   print('Position: ${position.text}');
//   print('Role: $role');
//   print('Status: $status');
//   print('Branch: ${branch.text}');
//   print('District: ${district.text}');
//   print('Salary: ${salary.text}');
//   print('Joining Date: ${joiningDate.toIso8601String()}');
//   print('Is Editing: $isEditing');
//   if (isEditing) {
//     print('Employee ID: ${widget.employeeData['id']}');
//   }

//   try {
//     final supabase = Supabase.instance.client;
    
//     final employeeData = {
//       'full_name': empName.text.trim(),
//       'email': email.text.trim(),
//       'phone': phone.text.trim(),
//       'position': position.text.trim(),
//       'branch': branch.text.trim(),
//       'district': district.text.trim(),
//       'joining_date': joiningDate.toIso8601String(),
//       'status': status,
//       'role': role,
//       'salary': int.tryParse(salary.text) ?? 0,
//     };
    
//     if (!isEditing) {
//       employeeData['performance'] = 0.0;
//       employeeData['attendance'] = 0.0;
//     } else {
//       employeeData['performance'] = widget.employeeData['performance'] ?? 0.0;
//       employeeData['attendance'] = widget.employeeData['attendance'] ?? 0.0;
//     }
    
//     print('Employee Data to Save: $employeeData');

//     if (isEditing) {
//       print('Updating employee with ID: ${widget.employeeData['id']}');
//       final response = await supabase
//           .from('emp_profile')
//           .update(employeeData)
//           .eq('id', widget.employeeData['id'])
//           .select();
      
//       print('Update Response: $response');
      
//       if (response.isNotEmpty) {
//         print('Update successful!');
//       }
//     } else {
//       final empId = generateEmpId();
//       employeeData['emp_id'] = empId;
      
//       print('Inserting new employee with EMP_ID: $empId');
//       final response = await supabase
//           .from('emp_profile')
//           .insert(employeeData)
//           .select();
      
//       print('Insert Response: $response');
      
//       if (response.isNotEmpty) {
//         print('Insert successful!');
//       }
//     }

//     if (!mounted) {
//       print('Context not mounted, returning');
//       return;
//     }
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(isEditing ? 'Employee updated successfully!' : 'Employee added successfully!'),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
    
//     await Future.delayed(const Duration(milliseconds: 1500));
    
//     Navigator.pop(context);
    
//   } catch (e, stackTrace) {
//     print('=== ERROR SAVING EMPLOYEE ===');
//     print('Error: $e');
//     print('Stack Trace: $stackTrace');
    
//     if (!mounted) return;
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error: ${e.toString()}'),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   } finally {
//     if (mounted) {
//       setState(() => loading = false);
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           isEditing ? "Edit Employee" : "Add New Employee",
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppColors.primaryBlue.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.person_add_alt_1,
//                       color: AppColors.primaryBlue,
//                       size: 30,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             isEditing ? "Edit Employee Details" : "Employee Registration",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primaryBlue,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             isEditing 
//                               ? "Update employee information as needed"
//                               : "Fill in the essential employee details",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Basic Information
//                     _sectionTitle("Basic Information"),
//                     const SizedBox(height: 12),
                    
//                     _buildTextField(
//                       controller: empName,
//                       label: "Employee Name",
//                       icon: Icons.person_outline,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: email,
//                       label: "Email Address",
//                       icon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       isRequired: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Email is required';
//                         }
//                         if (!value.contains('@')) {
//                           return 'Enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: phone,
//                       label: "Phone Number",
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                       isRequired: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Phone number is required';
//                         }
//                         if (value.length < 10) {
//                           return 'Enter a valid phone number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: position,
//                       label: "Position/Designation",
//                       icon: Icons.work_outline,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Role & Status Section
//                     _sectionTitle("Role & Status"),
//                     const SizedBox(height: 12),
                    
//                     // Role Dropdown - Clean UI
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: role,
//                         decoration: InputDecoration(
//                           labelText: "Role *",
//                           hintText: "Select Role",
//                           prefixIcon: Icon(
//                             Icons.groups,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'Employee',
//                             child: Text('Employee'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Marketing Manager',
//                             child: Text('Marketing Manager'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Production Manager',
//                             child: Text('Production Manager'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Owner',
//                             child: Text('Owner'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() => role = value);
//                           }
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Role is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Status Dropdown
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonFormField<String>(
//                         value: status,
//                         decoration: InputDecoration(
//                           labelText: "Status",
//                           hintText: "Select Status",
//                           prefixIcon: Icon(
//                             Icons.circle_outlined,
//                             color: AppColors.primaryBlue.withOpacity(0.7),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.borderGrey),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         items: const [
//                           'Active',
//                           'On Leave',
//                           'Probation',
//                           'Terminated',
//                           'Resigned',
//                         ].map((status) {
//                           return DropdownMenuItem<String>(
//                             value: status,
//                             child: Text(status),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() => status = value);
//                           }
//                         },
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Joining Date
//                     _buildDateField(
//                       date: joiningDate,
//                       label: "Joining Date",
//                       onDateSelected: (date) {
//                         setState(() => joiningDate = date);
//                       },
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Location & Salary
//                     _sectionTitle("Location & Compensation"),
//                     const SizedBox(height: 12),
                    
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildTextField(
//                             controller: branch,
//                             label: "Branch/Location",
//                             icon: Icons.location_on_outlined,
//                             isRequired: true,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildTextField(
//                             controller: district,
//                             label: "District",
//                             icon: Icons.map_outlined,
//                             isRequired: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
                    
//                     _buildTextField(
//                       controller: salary,
//                       label: "Monthly Salary (₹)",
//                       icon: Icons.currency_rupee_outlined,
//                       keyboardType: TextInputType.number,
//                       isRequired: true,
//                       prefixText: "₹ ",
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Salary is required';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'Enter valid amount';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),
                    
//                     // Role Information Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: _getRoleCardColor(),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _getRoleBorderColor(),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _getRoleIcon(),
//                             color: _getRoleColor(),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Role: $role",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: _getRoleColor(),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _getRoleDescription(),
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 32),
                    
//                     // Submit Button
//                     loading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.primaryBlue,
//                             ),
//                           )
//                         : SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: saveEmployee,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.primaryBlue,
//                                 elevation: 2,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     isEditing ? Icons.update : Icons.check_circle_outline, 
//                                     color: Colors.white
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     isEditing ? "UPDATE EMPLOYEE" : "SAVE EMPLOYEE",
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods for role styling
//   Color _getRoleColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple;
//       case 'Production Manager':
//         return Colors.orange;
//       case 'Owner':
//         return Colors.green;
//       default:
//         return AppColors.primaryBlue;
//     }
//   }

//   Color _getRoleCardColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple.withOpacity(0.05);
//       case 'Production Manager':
//         return Colors.orange.withOpacity(0.05);
//       case 'Owner':
//         return Colors.green.withOpacity(0.05);
//       default:
//         return AppColors.primaryBlue.withOpacity(0.05);
//     }
//   }

//   Color _getRoleBorderColor() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Colors.purple.withOpacity(0.2);
//       case 'Production Manager':
//         return Colors.orange.withOpacity(0.2);
//       case 'Owner':
//         return Colors.green.withOpacity(0.2);
//       default:
//         return AppColors.primaryBlue.withOpacity(0.1);
//     }
//   }

//   IconData _getRoleIcon() {
//     switch (role) {
//       case 'Marketing Manager':
//         return Icons.campaign_outlined;
//       case 'Production Manager':
//         return Icons.factory_outlined;
//       case 'Owner':
//         return Icons.verified_user_outlined;
//       default:
//         return Icons.person_outline;
//     }
//   }

//   String _getRoleDescription() {
//     switch (role) {
//       case 'Marketing Manager':
//         return "Will access Marketing Manager Dashboard with sales and marketing features";
//       case 'Production Manager':
//         return "Will access Production Manager Dashboard with inventory and production tools";
//       case 'Owner':
//         return "Will access Owner Dashboard with full administrative privileges";
//       default:
//         return "Will access Employee Dashboard with basic work features";
//     }
//   }

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: AppColors.primaryBlue,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isRequired = false,
//     TextInputType? keyboardType,
//     String? prefixText,
//     String? suffixText,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: isRequired ? "$label *" : label,
//           hintText: "Enter $label",
//           prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.7)),
//           prefixText: prefixText,
//           suffixText: suffixText,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         ),
//         validator: validator ?? (value) {
//           if (isRequired && (value == null || value.isEmpty)) {
//             return '$label is required';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildDateField({
//     required DateTime date,
//     required String label,
//     required Function(DateTime) onDateSelected,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: GestureDetector(
//         onTap: () async {
//           final selectedDate = await showDatePicker(
//             context: context,
//             initialDate: date,
//             firstDate: DateTime(2000),
//             lastDate: DateTime.now(),
//             builder: (context, child) {
//               return Theme(
//                 data: Theme.of(context).copyWith(
//                   colorScheme: ColorScheme.light(
//                     primary: AppColors.primaryBlue,
//                     onPrimary: Colors.white,
//                     surface: Colors.white,
//                     onSurface: Colors.black,
//                   ),
//                   dialogBackgroundColor: Colors.white,
//                 ),
//                 child: child!,
//               );
//             },
//           );
//           if (selectedDate != null) {
//             onDateSelected(selectedDate);
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.borderGrey),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.calendar_today_outlined,
//                 color: AppColors.primaryBlue.withOpacity(0.7),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       DateFormat('dd MMM yyyy').format(date),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_drop_down,
//                 color: Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






