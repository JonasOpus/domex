#Include "Protheus.ch"
#Include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Atualiza  �RFATA01    �Autor  �Marco Aurelio-OPUS � Data �  15/09/19   ���
�������������������������������������������������������������������������͹��    
���Programa  �RFATA01    �Autor  �Marco Aurelio-OPUS � Data �  09/02/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza Dados de Analise de Cr�dito no Cadastro de Clientes���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � DOMEX - Analise de Credito                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATA01()

Private cAlias := "SA1"

DbSelectArea(cAlias)
aRotina := {}

AADD(aRotina,{ "Pesquisar       ",'AxPesqui'     , 0, 1 } )
AADD(aRotina,{ "Visualizar      ",'AxVisual'     , 0, 2 } )
AADD(aRotina,{ "Cr�dito         ",'U_RDTCRED'  	 , 0, 3 } )

cCadastro := "Analise de Cr�dito - Manuten��o"
mBrowse( 6, 1,22,75,cAlias,,,,,,,,,,,,,,)  

Return



User Function RDTCRED()

Local _Retorno := .T.   

// Valida usuarios que podem acessar a rotina
if __CUSERID $ getmv("MV_XCRDANA")

			cLimite	:= SA1->A1_LC
			dVencLC	:= SA1->A1_VENCLC
			cRisco 	:= SA1->A1_RISCO
			cBloq 	:= SA1->A1_MSBLQL    
			cCondP	:= SA1->A1_COND
			
			aBloq		:= {'1=Sim','2=Nao'} 
			aRisco	:= {'A','B','C','D','E'}

	      @ 000,000 TO 200,500 DIALOG oDlgDI TITLE "An�lise de Cr�dito - ["+AllTrim(SA1->A1_COD)+"-"+AllTrim(SA1->A1_LOJA)+ "  "+AllTrim(SA1->A1_NREDUZ)+"]"
	      
	      @ 015, 005 SAY "Limite de Cr�dito:"
	      @ 015, 060 GET cLimite PICTURE "@E 999,999,999.99" SIZE 080,010
  
	      @ 015, 160 SAY "Risco:"
	      @ 015, 190 COMBOBOX oCombo1 VAR cRisco ITEMS aRISCO SIZE 20,10  VALID .T. PIXEL
	      		      
	      @ 030, 005 SAY "Vencimento Limite:"
	      @ 030, 060 GET dVencLC PICTURE "@!" SIZE 50,10
 
	      @ 030, 160 SAY "Cond.Pag:"
	      @ 030, 190 GET cCondP PICTURE "@!" SIZE 20,10 F3 "SE4"
	      	
	      @ 045, 005 SAY "Bloqueado? " //(1=SIM  / 2=NAO)"
	      @ 045, 060 COMBOBOX oCombo2  VAR cBloq ITEMS aBloq  SIZE 40,10  VALID .T. PIXEL 

	      @ 080,055 BUTTON "Confirmar" SIZE 040,012 ACTION _Gravar()
	      @ 080,110 BUTTON "Cancelar"  SIZE 040,012 ACTION _Sair()  
		ACTIVATE DIALOG oDlgDI CENTER

Else
	MsgAlert("MV_XCRDANA - Voc� n�o tem Acesso para executar esta Rotina. Solicite ao TI.")

Endif

Return _Retorno



Static Function _Gravar()

	if MsgYesNo("Confirma Grava��o dos Dados ?")
		RecLock("SA1", .F.)
			SA1->A1_LC 		:= cLimite
			SA1->A1_VENCLC	:= dVencLC
			SA1->A1_RISCO	:= cRisco
			SA1->A1_MSBLQL	:= cBloq	 
			SA1->A1_COND	:= cCondP		

		   Close(oDlgDI)
		MsUnLock()
	Endif
                                                                                                
Return


Static Function _Sair()

	Close(oDlgDI)

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �XRISCOE1�Autor  � Marco Aurelio-OPUS	 � Data �  15/05/19   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao de validacao dos campos do cliente e loja.		  ���
�������������������������������������������������������������������������͹��
���Uso       � MATX415                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER Function XRISCOE1()

Local aArea := GetArea()
Local lRet	:= .T.
//�����������������������������������Ŀ
//� Preenche a condi��o de pagamento. �
//�������������������������������������
dbSelectArea("SA1")
dbSetOrder(1)
If ReadVar() == "M->CJ_CLIENTE"

	If !Empty(M->CJ_LOJA)
		If dbSeek(xFilial("SA1") + M->CJ_CLIENTE + M->CJ_LOJA,.T.)
			M->CJ_LOJA	  := SA1->A1_LOJA
		ElseIf dbSeek(xFilial("SA1") + M->CJ_CLIENTE,.T.)
	 		M->CJ_LOJA 	  := SA1->A1_LOJA
		EndIf
	ElseIf dbSeek(xFilial("SA1") + M->CJ_CLIENTE,.T.)
		M->CJ_LOJA	  := SA1->A1_LOJA
	EndIf
ElseIf ReadVar() == "M->CJ_LOJA"
	dbSeek(xFilial("SA1") + M->CJ_CLIENTE + M->CJ_LOJA,.T.)
	if SA1->A1_MSBLQL == "1"
		MsgAlert("Cliente Bloqueado. Consulte Depto Financeiro.")
		lRet	:= .F.
	endif
EndIf

RestArea(aArea)

Return(lRet)


