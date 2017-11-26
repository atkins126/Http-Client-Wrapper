object ClientTestDlg: TClientTestDlg
  Left = 0
  Top = 0
  Caption = 'ClientTestDlg'
  ClientHeight = 201
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 294
    Top = 8
    Width = 145
    Height = 121
  end
  object Button1: TButton
    Left = 24
    Top = 25
    Width = 75
    Height = 25
    Caption = 'Get'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Post'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 103
    Top = 8
    Width = 185
    Height = 153
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Button3: TButton
    Left = 22
    Top = 87
    Width = 75
    Height = 25
    Caption = 'Post'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 22
    Top = 118
    Width = 75
    Height = 25
    Caption = 'Async Get'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 22
    Top = 149
    Width = 75
    Height = 25
    Caption = 'Async Post'
    TabOrder = 5
    OnClick = Button5Click
  end
end
