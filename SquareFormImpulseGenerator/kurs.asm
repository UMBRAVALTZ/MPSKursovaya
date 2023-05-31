.386
;������ ���� ��� � �����
RomSize    EQU   4096

			MatrixPowerPortL = 0FBh; ������ 0-7
			MatrixPowerPortH = 0F7h; ������ 8-15
			MatrixColumnPort = 0FEh;
			MatrixRowPort = 0FDh;
			DisplayPowerPort = 0EFh ;0-2 �����, 3 ������㤠, 4 ���⥫쭮��� ������
			DisplaySegmentsPort = 0DFh
			KeyboardPort = 0FEh
			MS = 1000
			NMax = 50

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����

			FrequancyBCD db 2 dup(?)
			FrequancyImage db 3 dup(?)

			Frequancy db ?
			Amplitude db ?
			PulseDuration db ?
			PauseDuration db ?
			PulsePeriod db ?

			NoInputErrorFlag db ?

			PolarityFlag db ?

			DataHexArr db 10 dup(?)
			DataHexTabl db 10 dup(?)

			KeyImage db ? ; FF: ��祣�, FE: + Freq, FD: - Freq, FB: + Ampl, F7: - Ampl, EF: + PulDur, DF: - PulDur, BF: Generation, 7F: Polarity
			OldButton db ?

			PulsesImage db 128 dup(?)

			PulsesCount db ?

			StartPosition db ?




Data       ENDS

;������ ����室��� ���� �⥪�
Stack        SEGMENT use16 AT 2000h
;������ ����室��� ࠧ��� �⥪�
           dw    16 dup (?)
StackTop     Label Word
Stack        ENDS

InitData   SEGMENT use16
InitDataStart:
;����� ࠧ������� ���ᠭ�� ����⠭�



InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

			ASSUME cs:Code,ds:Data,es:Data
			HexArr DB 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
			HexTabl DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
			
Initialization PROC 
			CALL CopyArraysToDataSegment
			XOR AX, AX
			MOV Frequancy, 20
			MOV FrequancyImage+0, AH
			MOV FrequancyImage+1, AH
			MOV FrequancyImage+2, AH
			MOV FrequancyBCD+0, AH
			MOV FrequancyBCD+1, AH
			MOV FrequancyBCD+2, AH
			MOV Amplitude, 5; ������㤠 = 0
			MOV PulseDuration, 5
			MOV PulsePeriod, AH
			MOV NoInputErrorFlag, 0FFh
			MOV OldButton, AH
			MOV KeyImage, 0FFh
			MOV PulsesCount, AH
			MOV PolarityFlag, AH
			LEA DI, PulsesImage
			MOV CX, 128
M1:			MOV [DI], AL
			INC DI
			LOOP M1
			
			RET
Initialization ENDP

Delay PROC NEAR

Delay ENDP
		   
DisplayFrequancy     PROC  ;�뢮� ����� �� ��ᯫ��
			LEA BX, DataHexTabl 
            MOV AH, FrequancyImage+0
            MOV AL, AH               ;⥯��� � al ����� ���
            XLAT
		    NOT AL		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            OUT DisplaySegmentsPort, AL    ;�뢮��� �� ���訩 ��������
            MOV AL, 1            
            OUT DisplayPowerPort, AL    ;�������� ���訩 ��������    
            MOV AL,00h             
            OUT DisplayPowerPort, AL    ;��ᨬ ��������
		    MOV AH, FrequancyImage+1      ;����㦠�� � ॣ�����
            MOV AL, AH              ;⥪�饥 ���祭�� �㬬�                 
            XLAT
		    NOT AL ;⠡��筮� �८�ࠧ������ ����襩 ����
            OUT DisplaySegmentsPort, AL    ;�뢮��� �� ����訩 ��������            
            MOV AL, 2            
            OUT DisplayPowerPort, AL    ;�������� ����訩 ��������
            MOV AL,00h
            OUT DisplayPowerPort, AL    ;��ᨬ ��������
			MOV AH, FrequancyImage+2      ;����㦠�� � ॣ�����
            MOV AL, AH              ;⥪�饥 ���祭�� �㬬�                 
            XLAT
		    NOT AL ;⠡��筮� �८�ࠧ������ ����襩 ����
            OUT DisplaySegmentsPort, AL    ;�뢮��� �� ����訩 ��������            
            MOV AL, 4            
            OUT DisplayPowerPort, AL    ;�������� ����訩 ��������
            MOV AL,00h
            OUT DisplayPowerPort, AL    ;��ᨬ ��������
            RET
DisplayFrequancy     ENDP

DisplayAmplitude     PROC  ;�뢮� �������� �� ��ᯫ��
			LEA BX, DataHexTabl 
            MOV AL, Amplitude
            XLAT
		    NOT AL		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            OUT DisplaySegmentsPort, AL    ;�뢮��� �� ���訩 ��������
            MOV AL, 8            
            OUT DisplayPowerPort, AL    ;�������� ���訩 ��������    
            MOV AL,00h             
            OUT DisplayPowerPort, AL    ;��ᨬ ��������
            RET
DisplayAmplitude     ENDP

DisplayPulseDuration     PROC  ;�뢮� ���⥫쭮�� ������ �� ��ᯫ��
			LEA BX, DataHexTabl 
            MOV AL, PulseDuration
            XLAT
		    NOT AL		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            OUT DisplaySegmentsPort, AL    ;�뢮��� �� ���訩 ��������
            MOV AL, 16            
            OUT DisplayPowerPort, AL    ;�������� ���訩 ��������    
            MOV AL,00h             
            OUT DisplayPowerPort, AL    ;��ᨬ ��������
            RET
DisplayPulseDuration     ENDP

CopyArraysToDataSegment PROC 
			MOV CX, 10 ;����㧪� ����稪� 横���
			LEA BX, HexArr ;����㧪� ���� ���ᨢ� ���
			LEA BP, HexTabl ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA DI, DataHexArr ;����㧪� ���� ���ᨢ� ��� � ᥣ���� ������
			LEA SI, DataHexTabl ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
M0:
			MOV AL, CS:[BX] ;�⥭�� ���� �� ���ᨢ� � ��������
			MOV [DI], AL ;������ ���� � ᥣ���� ������/DataHexArr
			INC BX ;����䨪��� ���� HexArr
			INC DI ;����䨪��� ���� DataHexArr
			LOOP M0
			
			MOV CX, 10 ;����㧪� ����稪� 横���
M1:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataHexTabl
			INC BP ;����䨪��� ���� HexTabl
			INC SI ;����䨪��� ���� DataHexTabl
			LOOP M1
			XOR BP,BP
			RET
CopyArraysToDataSegment ENDP

PulsePeriodAndPauseCalculation PROC  
			MOV AX, MS
			DIV Frequancy
			MOV PulsePeriod, AL
			SUB AL, PulseDuration
			MOV PauseDuration, AL
			RET
PulsePeriodAndPauseCalculation ENDP

PulsesCountCalculation PROC 
			XOR AX, AX
			MOV AL, LENGTH PulsesImage
			DIV PulsePeriod
			MOV PulsesCount, AL
			RET
PulsesCountCalculation ENDP

FrequancyAddition PROC 
			CMP KeyImage, 0FEh
			JNZ M1
			CMP Frequancy, 150
			JZ M1
			ADD Frequancy, 10			
M1:			RET
FrequancyAddition ENDP

FrequancySubtraction PROC 
			CMP KeyImage, 0FDh
			JNZ M1
			CMP Frequancy, 20
			JZ M1
			SUB Frequancy, 10			
M1:			RET
FrequancySubtraction ENDP

AmplitudeAddition PROC 
			CMP KeyImage, 0FBh
			JNZ M1
			CMP Amplitude, 5
			JZ M1		
			INC Amplitude			
M1:			RET
AmplitudeAddition ENDP

AmplitudeSubtraction PROC 
			CMP KeyImage, 0F7h
			JNZ M1
			CMP Amplitude, 0
			JZ M1			
			DEC Amplitude		
M1:			RET
AmplitudeSubtraction ENDP

PulseDurationAddition PROC 
			CMP KeyImage, 0EFh
			JNZ M1
			CMP PulseDuration, 5
			JZ M1
			INC PulseDuration			
M1:			RET
PulseDurationAddition ENDP

PulseDurationSubtraction PROC 
			CMP KeyImage, 0DFh
			JNZ M1
			CMP PulseDuration, 1
			JZ M1
			DEC PulseDuration			
M1:			RET
PulseDurationSubtraction ENDP

BinaryToBCD PROC 
			XOR BX, BX
			MOV FrequancyBCD+0, BL
			MOV FrequancyBCD+1, BL
			MOV FrequancyBCD+2, BL
			MOV BL, Frequancy
			MOV CX, 8
M2:			LEA DI, FrequancyBCD
			SHL BL, 1
			PUSH CX
			MOV CX, 2
M1:			MOV AL, [DI]
			ADC AL, [DI]
			DAA
			MOV [DI], AL
			INC DI
			LOOP M1
			POP CX
			LOOP M2
			RET
BinaryToBCD ENDP

UnpackFrequancyBCD PROC 
			MOV AL, FrequancyBCD+0
			MOV BL, AL
			AND AL, 0Fh
			MOV FrequancyImage+0, AL
			SHR BL,4
			MOV FrequancyImage+1, BL
			MOV AL, FrequancyBCD+1
			AND AL, 0Fh
			MOV FrequancyImage+2, AL
			RET
UnpackFrequancyBCD ENDP

KeyRead    PROC   ;�⥭�� ������
			MOV DX, KeyboardPort
            IN AL, KeyboardPort
			CALL VibrDestr
            MOV AH, AL
            XOR AL, OldButton
            AND AL, AH
			NOT AL
			MOV OldButton, AH
			MOV KeyImage, AL
            
						
			RET
KeyRead    ENDP

KeyCheck PROC 
			CMP KeyImage, 0FFh
			JNZ M1
			MOV NoInputErrorFlag, 0FFh
			JMP M2
M1:			MOV NoInputErrorFlag, 00h
M2:			RET
KeyCheck ENDP

VibrDestr  PROC  
VD1:        mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
            mov   bh,0        ;���� ����稪� ����७��
VD2:        in    al,dx       ;���� ⥪�饣� ���ﭨ�
            cmp   ah,al       ;����饥 ���ﭨ�=��室����?
            jne   VD1         ;���室, �᫨ ���
            inc   bh          ;���६��� ����稪� ����७��
            cmp   bh,NMax     ;����� �ॡ����?
            jne   VD2         ;���室, �᫨ ���
            mov   al,ah       ;����⠭������� ���⮯�������� ������
            ret
VibrDestr  ENDP

PolaritySetting PROC 
			CMP KeyImage, 0BFh
			JNZ M1
			NOT PolarityFlag
M1:			RET
PolaritySetting ENDP

DataSetting PROC 
			CMP NoInputErrorFlag, 0FFh
			JZ M1
			CALL FrequancyAddition
			CALL FrequancySubtraction
			CALL AmplitudeAddition
			CALL AmplitudeSubtraction
			CALL PulseDurationAddition
			CALL PulseDurationSubtraction
			CALL PolaritySetting
			CALL PulsePeriodAndPauseCalculation
			CALL PulsesCountCalculation
			CALL StartPositionSetting
M1:			
			RET
DataSetting ENDP

PulseImageForming PROC 
			LEA BX, PulsesImage
			XOR DI, DI
			
			CALL XAxisForming
			
			CMP Amplitude, 00h
			JZ M2
			XOR DI, DI
			
			MOV CL, PulsesCount
			INC CL
			
M1:			PUSH CX

			CALL AmplitudeUpImageForming
			CALL PulseDurationImageForming
			CALL AmplitudeDownImageForming
			CALL PauseDurationImageForming
			
			POP CX
			LOOP M1
M2:			RET
PulseImageForming ENDP

XAxisForming PROC 

			MOV CL, 128
			MOV AH, StartPosition
			MOV AL, AH
			
			CMP PolarityFlag, 0FFh
			JNZ M1
			SHR AH, 2
			CMP Amplitude, 00h
			JNZ M2
			OR AH, AL
			JMP M2
			
M1:			SHL AH, 2
			CMP Amplitude, 00h
			JNZ M2
			OR AH, AL

M2:			OR [BX+DI], AH
			AND [BX+DI], AH
			INC DI
			LOOP M2

			RET
XAxisForming ENDP


AmplitudeUpImageForming PROC 
			MOV CL, Amplitude
			MOV AH, StartPosition
M1:			CMP DI, 128
			JZ M7
			OR [BX+DI], AH
			CMP PolarityFlag, 00h
			JNZ M2
			SHR AH, 1
			JMP M3
M2:			SHL AH, 1
			
M3:			LOOP M1
M7:			RET
AmplitudeUpImageForming ENDP

PulseDurationImageForming PROC 
			CMP PulseDuration, 1
			JZ M7
			MOV CL, PulseDuration; ���⥫쭮��� ������ - 1
			DEC CL
M2:			CMP DI, 128
			JZ M7
			OR [BX+DI], AH
			INC DI
			LOOP M2
M7:			RET
PulseDurationImageForming ENDP

AmplitudeDownImageForming PROC 
			MOV CL, Amplitude
M1:			CMP DI, 128
			JZ M7
			OR [BX+DI], AH
			CMP PolarityFlag, 00h
			JNZ M2
			SHL AH, 1
			JMP M3
M2:			SHR AH, 1
M3:			LOOP M1
M7:			RET
AmplitudeDownImageForming ENDP

PauseDurationImageForming PROC 
			MOV CL, PauseDuration
			INC CL
M4:			CMP DI, 128
			JZ M7
			OR [BX+DI], AH
			INC DI
			LOOP M4
M7:			RET
PauseDurationImageForming ENDP

MatrixOutput PROC 
			LEA SI, PulsesImage
			MOV DL, MatrixPowerPortL
			MOV BL, 1
			MOV AH, 1
			MOV CX, 2
M3:			PUSH CX
			
			MOV CX, 8
			
M2:			PUSH CX
			MOV AL, BL
			OUT DX, AL
			
			MOV CX, 8
			
M1:			MOV AL, [SI]
			OUT MatrixRowPort, AL
			MOV AL, AH
			OUT MatrixColumnPort, AL
			MOV AL, 0
			OUT MatrixRowPort, AL
			OUT MatrixColumnPort, AL
			ROL AH, 1
			INC SI
			LOOP M1
			MOV AL, 0
			OUT DX, AL 
			ROL BL, 1
			POP CX
			LOOP M2
			
			POP CX
			ROL DL, 1
			LOOP M3
			RET
MatrixOutput ENDP

StartPositionSetting PROC 
			CMP PolarityFlag, 00h
			JNZ M1
			MOV StartPosition, 20h
			JMP M2
M1:			MOV StartPosition, 04h
M2:			
			RET
StartPositionSetting ENDP

DisplayData PROC 
			CALL DisplayFrequancy
			CALL DisplayAmplitude
			CALL DisplayPulseDuration
			RET
DisplayData ENDP

Start:
            mov   ax,Data
            mov   ds,ax
            mov   es,ax
            mov   ax,Stack
            mov   ss,ax
            lea   sp,StackTop
			
;����� ࠧ��頥��� ��� �ணࠬ��
			CALL Initialization
ILOOP:
			CALL KeyRead
			CALL KeyCheck
			CALL DataSetting
			CALL BinaryToBCD
			CALL UnpackFrequancyBCD		
			CALL DisplayData
			CALL PulseImageForming
			CALL MatrixOutput
			JMP ILOOP

;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
