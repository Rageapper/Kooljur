import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/school_service.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/l10n/app_localizations.dart';

class SelectSchoolScreen extends StatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  State<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends State<SelectSchoolScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSchoolName;
  String? _selectedSchoolAddress;
  bool _isLoading = false;
  List<SchoolModel> _allSchools = [];
  bool _isLoadingSchools = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedSchool();
    _loadSchools();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadSchools() async {
    setState(() {
      _isLoadingSchools = true;
    });
    final schools = await DataService.getAllSchools();
    if (mounted) {
      setState(() {
        _allSchools = schools;
        _isLoadingSchools = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedSchool() async {
    final schoolName = await SchoolService.getSelectedSchoolName();
    final schoolAddress = await SchoolService.getSelectedSchoolAddress();
    if (mounted) {
      setState(() {
        _selectedSchoolName = schoolName;
        _selectedSchoolAddress = schoolAddress;
      });
    }
  }

  Future<void> _selectSchool(SchoolModel school) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Сохраняем в локальное хранилище
      await SchoolService.setSelectedSchool(school.name, school.address);

      // Обновляем в профиле пользователя
      final currentUser = await DataService.getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(school: school.name);
        await DataService.updateUser(updatedUser);
      }

      if (mounted) {
        setState(() {
          _selectedSchoolName = school.name;
          _selectedSchoolAddress = school.address;
          _isLoading = false;
        });

        // Возвращаемся назад сразу после сохранения
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Убрано уведомление об ошибке - можно добавить диалог при необходимости
      }
    }
  }

  List<SchoolModel> get _filteredSchools {
    if (_searchQuery.isEmpty) {
      return _allSchools;
    }
    return _allSchools.where((school) {
      return school.name.toLowerCase().contains(_searchQuery) ||
          school.address.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getCardColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getWhite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations?.selectAnotherSchool ?? 'Выбрать школу',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: localizations?.search ?? 'Поиск школы...',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingSchools
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getAccentColor(context),
                    ),
                  )
                : _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getAccentColor(context),
                    ),
                  )
                : _filteredSchools.isEmpty
                ? Center(
                    child: Text(
                      localizations?.noResults ?? 'Школы не найдены',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _filteredSchools.map((school) {
                      final isSelected = _selectedSchoolName == school.name;
                      return _buildSchoolCard(
                        context: context,
                        name: school.name,
                        address: school.address,
                        isSelected: isSelected,
                        onTap: () => _selectSchool(school),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCard({
    required BuildContext context,
    required String name,
    required String address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.getAccentColor(context).withOpacity(0.1),
      highlightColor: AppColors.getAccentColor(context).withOpacity(0.05),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.getAccentColor(context), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.getAccentColor(context).withOpacity(0.2)
                    : AppColors.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school,
                color: isSelected
                    ? AppColors.getAccentColor(context)
                    : AppColors.getWhite(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.getAccentColor(context),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
