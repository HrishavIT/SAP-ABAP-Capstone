*&---------------------------------------------------------------------*
*& Report  : ZHRISH_EMP_ALV
*& Title   : Custom ALV Report - Employee Master Data
*& Author  : Hrishav Raj Singh
*& Roll No : 2306284
*& Program : Information Technology (IT)
*& Date    : April 2026
*& Desc    : Displays employee master data from HR infotypes PA0001 and
*&           PA0002 with selection screen filters and ALV grid output.
*&---------------------------------------------------------------------*

REPORT ZHRISH_EMP_ALV.

TABLES: PA0001, PA0002.

*----------------------------------------------------------------------*
* Type Definition
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_emp,
  pernr TYPE pa0001-pernr,    "Personnel Number
  ename TYPE pa0002-nachn,    "Last Name
  vorna TYPE pa0002-vorna,    "First Name
  werks TYPE pa0001-werks,    "Personnel Area
  persg TYPE pa0001-persg,    "Employee Group
  persk TYPE pa0001-persk,    "Employee Subgroup
  kostl TYPE pa0001-kostl,    "Cost Center
END OF ty_emp.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*
DATA: lt_emp    TYPE TABLE OF ty_emp,
      ls_emp    TYPE ty_emp,
      lt_fcat   TYPE slis_t_fieldcat_alv,
      ls_fcat   TYPE slis_fieldcat_alv,
      ls_layout TYPE slis_layout_alv.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_werks FOR pa0001-werks,    "Personnel Area
                s_persg FOR pa0001-persg,    "Employee Group
                s_kostl FOR pa0001-kostl.    "Cost Center
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.

  "Fetch data from HR Infotypes PA0001 and PA0002
  SELECT a~pernr b~nachn b~vorna a~werks a~persg a~persk a~kostl
    INTO TABLE lt_emp
    FROM pa0001 AS a
    INNER JOIN pa0002 AS b ON b~pernr = a~pernr
    WHERE a~werks IN s_werks
      AND a~persg IN s_persg
      AND a~kostl IN s_kostl
      AND a~endda >= sy-datum.    "Only active records

  "Check if data was found
  IF lt_emp IS INITIAL.
    MESSAGE 'No records found for the given selection criteria.' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM build_fieldcat.
  PERFORM display_alv.

*----------------------------------------------------------------------*
* Form: build_fieldcat
* Builds the ALV field catalog (column definitions)
*----------------------------------------------------------------------*
FORM build_fieldcat.

  DEFINE add_field.
    CLEAR ls_fcat.
    ls_fcat-fieldname = &1.
    ls_fcat-seltext_m = &2.
    ls_fcat-outputlen  = &3.
    APPEND ls_fcat TO lt_fcat.
  END-OF-DEFINITION.

  add_field 'PERNR' 'Emp No'      8.
  add_field 'ENAME' 'Last Name'   20.
  add_field 'VORNA' 'First Name'  20.
  add_field 'WERKS' 'Pers. Area'  10.
  add_field 'PERSG' 'Emp Group'   5.
  add_field 'PERSK' 'Emp Subgrp'  5.
  add_field 'KOSTL' 'Cost Center' 10.

ENDFORM.

*----------------------------------------------------------------------*
* Form: display_alv
* Displays data using REUSE_ALV_GRID_DISPLAY function module
*----------------------------------------------------------------------*
FORM display_alv.

  "ALV Layout settings
  ls_layout-zebra             = 'X'.    "Alternating row colors
  ls_layout-colwidth_optimize = 'X'.    "Auto column width

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat      = lt_fcat
      is_layout        = ls_layout
      i_callback_program = sy-repid
    TABLES
      t_outtab         = lt_emp
    EXCEPTIONS
      program_error    = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error occurred while displaying ALV report.' TYPE 'E'.
  ENDIF.

ENDFORM.
