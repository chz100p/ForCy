						Osamu Tamura


		ForCy for ATmega88x �\�[�X�R�[�h


	�t�@�C�����X�g

\ForCy
��  readme.txt
��  fcc.f			ForCy �R���p�C���i���ԃR�[�h�j
��  fcy.exe			ForCy �V�~�����[�^
��  go.bat			�V�~�����[�^�̃o�b�`
��  lint.bat			�X�^�b�N�g���[�X�̃o�b�`
��  echo.txt			�ȉ��T���v���v���O�����i* �͎��@�ł̂ݓ���j
��  eeprom.txt		*
��  haiku.txt
��  hanoi.txt
��  hello.txt
��  intr.txt
��  jello.txt
��  lex.txt
��  mul.txt
��  music.txt			*
��  pi.txt
��  piano.txt			*
��  qsort.txt
��  queen.txt
��  rcrs.txt
��  test.txt
��  
����at88x
��      fcc.asm		../src/at88.bat �Ő��������R���p�C��
��      forcyavr.aps
��      ForCyAVR.hex		ATmega88 �̏������݃v���O�����i�g�d�w�`���j
��      ForCyAVR.lst
��      ForCyAVR.map
��      ForCyAVR.obj
��      main.asm		ForCy �C���^�[�v���^�i�A�Z���u���j
��      
����src
        at88.bat		�t�@�[���E�F�A�p�R���p�C�������o�b�`
        compiler.c		ForCy �R���p�C��
        compiler.obj
        f2avr.exe		���ԃR�[�h �� asm �ϊ��c�[��
        fcc.f
        fcc.fc		ForCy ���ȋL�q�R���p�C��
        fcy.exe
        forcy.h		ForCy �w�b�_�t�@�C��
        interprt.c		ForCy �C���^�[�v���^
        interprt.obj
        lint.c		�X�^�b�N�g���[�X�@�\
        lint.h
        lint.obj
        main.c
        main.obj
        makefcc.bat		���ȋL�q�R���p�C�������o�b�`
        makefile		fcy.exe �����p
        monAT88x.fc		ATmega88 �p���j�^
        


�P�DForCy �V�~�����[�^�̎��s
�@�R�}���h�v�����v�g���N�����A�V�~�����[�^�ƃT���v���̃f�B���N�g�����J�����g�ɂ���B
	go hello
�ȂǂƂ���΂o�b��ŃV�~�����[�g���s����B


�Q�D�X�^�b�N�g���[�X�@�\
�@���l�ɁA
	lint hello 1
�ȂǂƂ���΁A�e��`���[�h�ł̃X�^�b�N������\������B
	lint hello 2
�Ƃ���΁A���ׂĂ̒�`���[�h�̃X�^�b�N������\������B
{ } ���ŃX�^�b�N�o�����X�������ƌx������i music.txt �Ȃǁj�B


�R�D�t�@�[���E�F�A�X�V�iVer. 0.88 �ȍ~�j
 (1) SW1, 2 �̗������������܂�RESET�������B
 (2) '=' ���\�������B
 (3) �n�C�p�[�^�[�~�i���Ȃǂ� at88x/ForCyAVR.hex �𑗂�B
�@�i�e�L�X�g�G�f�B�^�ŊJ���ăR�s�[���y�[�X�g����j
 (4) =oooooooooooooo ���� ooooooooooooooooo/ ���\�������B
 (5) �ċN�������B

�@AVR Studio ���g���ăA�Z���u����b�Ńv���O�������쐬����΁A
�t�@�[���E�F�A�X�V�@�\�Ń��[�h���s�ł��܂��B�v���O������������
�V�j�o�C�g�����p�ł��܂��Bat88x/main.asm ���Q�l�ɁA�V�j�o�C�g�߂�
�J�n�A�h���X�����Ă��������B


�S�DATmega88 �ւ̏�������
 (1) AVR �p�̏������݊��p�ӂ���iATmega88 �Ή��̂��́j�B
 (2) �q���[�Y�͈ȉ���ݒ肷��B(FA, EE, E2)
	BOOTSZ=01
	BOOTRST=0
	RSTDISBL=1
	WDTON=0
	BODLEVEL=110
	CKSEL=0010 SUT=10
 (3) Boot Loader Protection Mode 2 �Ƃ��ă��b�N����B
 (4) at88x/ForCyAVR.hex ���������ށB


�T�D�V�X�e����`���[�h�ǉ��菇

��PC�p�R���p�C���E�C���^�[�v���^�̏C��
�Eforcy.h �̗񋓎q�����iiEND�̑O�j��ID��ǉ��iiUSRCMD �Ȃǁj
�Einterprt.c �ɑΉ����鏈����ǉ�
�Ecompiler.c �̃��[�h����������iconst char *sysdic)�Ƀ��[�h����ǉ��i�����񖖔��ɂ̓X�y�[�X�����邱�Ɓj

1. C�ŋL�q���ꂽPC�p�� ForCy�R���p�C���{�C���^�[�v���^���r���h�imakefile�j
�@Visual C++ �Ȃǁ@���@fcy.exe


�����ȋL�q�R���p�C���̏C��
�Efcc.fc �̃��[�h����������isysdic)�Ƀ��[�h����ǉ��i�����񖖔��ɂ̓X�y�[�X�����邱�Ɓj

2. fcy.exe ��� ForCy���ȋL�q�R���p�C�� fcc.fc ���r���h(makefcc) -> fcc.f

�����������R���p�C���� PC��œ���m�F

3. fcc.f + fcy.exe�i�̃C���^�[�v���^�����j�� ForCy�v���O�������V�~�����[�g(go *.txt)


4. ForCy���ȋL�q�R���p�C�� + ATmega88�p���j�^ �� ATmega88�p�Ƀr���h(at88) -> fcc.asm

5. AVR Studio 4 �� forcyavr�v���W�F�N�g��ǂݍ���

��ATmega88 �̃C���^�[�v���^���g��
�Emain.asm�ɕ���e�[�u����ǉ����A�Ή����鏈�����A�Z���u���L�q

6. �r���h -> forcyavr.hex �� ATmega88 �֏�������
 

(2006/05/16)
(2007/01/27: �q���[�Y�r�b�g������j

