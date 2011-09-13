//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Dokuro Sep 8, 2011 - Initial Contribution
//

using fwt
using gfx

**
**
**
public class VirtualBarcode
{
  Text iban := Text { prefCols = 16;  }
  Text sum := Text { text = "1"; prefCols = 7 }
  Text reference := Text { text = "48151 63242"; prefCols = 20 }
  Text due := Text { prefCols = 6 }
  
  Text virtualBarCode := Text { text = "111"; prefCols = 54 ; editable = false }
  
  public new make() {
    DateTime time := DateTime.now
    
    due.text = time.year.toStr[2..3] + (time.month.ordinal + 1).toStr.padl(2, '0') + time.day.toStr.padl(2, '0')
    
    Window { 
      content = InsetPane(5) { 
        content = EdgePane { 
          center = GridPane { 
            numCols = 2
            
            Label { text = "IBAN" }, 
            iban,
            
            Label { text = "Summa" }, 
            sum,
            
            Label { text = "Viite" }, 
            reference,
            
            Label { text = "Eräpäivä" }, 
            due,
          }
          bottom = InsetPane(10, 0) {
            content = GridPane {
              numCols = 1
              vgap = 10
              
              Button { text = "Generoi viivakoodi"; onAction.add { virtualBarCode.text = generate() } },
              virtualBarCode,
            }
          }
        }
      }
    }.open 
  }

  
  private Str generate() {
    Str version := "4"
    Str spare := "000"
    
    Str euros := toEuros()
    Str cents := toCents()
    
    return version + trim(iban.text) + euros + cents + spare + withChecksum(trim(reference.text)) + due.text
  }
    
  private Str withChecksum(Str reference) {
    if (checksum(reference.padl(20, '0')) % 10 == 0) {
      return reference.padl(20, '0')
    }
    
    Str padded := reference.padl(19, '0')

    return padded + (10 - (checksum(padded) % 10))
  }
  
  private Int checksum(Str reference) {
    Int i := 1
    Int sum := 0
    reference.each |Int char -> Void| { 
      Int factor := ((i + 1) % 3) * ((i + 1) % 3 + 1) + 1
      sum += Str.fromChars([char]).toInt * factor
      i++
    }
    
    return sum
  }
  
  private Str trim(Str s) {
    return s.replace(" ", "")
  }
  
  private Str toEuros() {
    Decimal dsum := Decimal.fromStr(sum.text)
    Int euros := dsum.toInt
    return euros.toStr.padl(6, '0')
  }
  
  private Str toCents() {
    Decimal dsum := Decimal.fromStr(sum.text)
    Int cents := ((dsum - dsum.toInt) * 100).toInt
    return cents.toStr.padl(2, '0')
  }
  
	public static Void main(Str[] args)
	{
	  VirtualBarcode hw := VirtualBarcode()
	}
}
