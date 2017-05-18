object TestForm: TTestForm
  Left = 0
  Top = 0
  Caption = 'Variable Stream Example'
  ClientHeight = 429
  ClientWidth = 867
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 16
    Width = 305
    Height = 161
    Lines.Strings = (
      'Use a TVariableStream to store data with different sizes.'
      'For example, "String" of different lengths.'
      ''
      'The following features are executed FAST:'
      ''
      'Append'
      'Clear'
      'Delete'
      'Get ( Value := Data[123] )'
      'Modify ( Data[123] := NewValue )'
      '')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 88
    Top = 200
    Width = 153
    Height = 25
    Caption = 'Test in-memory'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 72
    Top = 312
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo2')
    TabOrder = 2
  end
  object ListBox1: TListBox
    Left = 352
    Top = 16
    Width = 153
    Height = 385
    ItemHeight = 13
    TabOrder = 3
  end
  object Button2: TButton
    Left = 88
    Top = 247
    Width = 153
    Height = 25
    Caption = 'Test File streams'
    TabOrder = 4
    OnClick = Button2Click
  end
  object ListBox2: TListBox
    Left = 528
    Top = 16
    Width = 153
    Height = 385
    ItemHeight = 13
    TabOrder = 5
  end
  object ListBox3: TListBox
    Left = 696
    Top = 16
    Width = 153
    Height = 385
    ItemHeight = 13
    TabOrder = 6
  end
end
