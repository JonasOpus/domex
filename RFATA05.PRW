#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RFATA05   �Autor  �Marco Aurelo-OPUS   � Data �  15/05/19   ���
�������������������������������������������������������������������������͹��
���Prog.ORI  �ORC001    �Autor  �Marco Aurelo-OPUS   � Data �  11/09/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilhos para Pedido de Venda - Analise Credito            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Domex                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������

Parametros:
//

"A" - Somente Exibe Mensagem ao preencher o Campo Cliente
"B" - Valida Condicao de Pagamento pelo Campo E4_XRISCOE  como Logico
"C" - Valida Condicao de Pagamento do cadastro de Clientes (A1_COND) pelo Campo E4_XRISCOE  como Logico

*/

//KSDKAJKDKASJDKKDKJKDJ
//HUAHAHAUHAUHA
// mauresi

User Function RFATA05()

Local _Retorno := .T.
//Local _cCampo	:= ReadVar()
Local _cCampo := StrTran(ReadVar(),"M->","")


If SuperGetMV("MV_XANACRE")  .and. M->C5_TIPO $ "N"      // Adicionado Tratamento para So executar em Pedido Tipo N

	If _cCampo $ "C5_CLIENTE,C5_CONDPAG,C5_LOJACLI"  // _cTipo   $  "A/B" 
		_cCliente:=	M->C5_CLIENTE
		_cLoja	:=	iif(empty(M->C5_LOJACLI),"01",M->C5_LOJACLI)
		
	//	cRisco := Alltrim(Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_RISCO"))
		cRisco := Alltrim(Posicione("SA1",1,xFilial("SA1") + _cCliente + _cLoja,"A1_RISCO"))
		cCondE := Posicione("SE4",1,xFilial("SE4") + M->C5_CONDPAG,"E4_XRISCOE")
	elseif _cCampo $ "A1_COND" //_cTipo   == "C"
		cRisco := M->A1_RISCO
		cCondE := Posicione("SE4",1,xFilial("SE4") + M->A1_COND,"E4_XRISCOE")
	Endif
	
	
	//��������������������������������������������������������������������Ŀ
	//�Mensagem para Cliente - funcao carregada no SX3 do campo C5_CLIENTE �
	//����������������������������������������������������������������������
	if _cCampo $ "C5_CLIENTE,C5_LOJACLI" //_cTipo $ "A"
		if cRisco $ "E"
			MsgInfo("Cliente com Risco 'E'. ")
		Endif
	Endif
	
	//������������������������������������������������������������������������������������������Ŀ
	//�Valida Condicao de Pagamento (C5_CONDPAG) - funcao carregada no SX3 do campo C5_CONDPAG   �
	//��������������������������������������������������������������������������������������������
	if _cCampo $ "C5_CONDPAG"  // _cTipo $ "B"
		if cRisco $ "E"
			if !cCondE	// Se nao for Cond.Pagto permitida para Risco E
				MsgAlert("Condicao de Pagamento Nao Permitida para Este Cliente, pois ele tem Risco 'E'. ")
				_Retorno := .F.
			Endif
		Endif
	Endif
	
	//������������������������������������������������������������������������������������������Ŀ
	//�Valida Condicao de Pagamento (A1_COND) - funcao carregada no SX3 do campo A1_COND         �
	//��������������������������������������������������������������������������������������������
	If _cCampo $ "A1_COND" // _cTipo $ "C"
		If cRisco $ "E"
			If !cCondE	// Se nao for Cond.Pagto permitida para Risco E
				MsgAlert("Condicao de Pagamento Nao Permitida para Este Cliente, pois ele tem Risco 'E'. ")
				_Retorno := .F.
			EndIf
		EndIf
	EndIf
	
	
	//������������������������������������������������������������������������������������������Ŀ
	//� Atualiza Flag do campo (C5_XSTATUS) Liberacao do Orcamento                               �
	//� A=Aguardando Liberacao    (LARANJA)                                                      �
	//� B=Aguardando Autorizacao Cartao de Credito (BRANCO)                                      �
	//� C=Autorizado Cartao de Credito  (VIOLETA)                                                �
	//��������������������������������������������������������������������������������������������
	/*
	If _cCampo $ "C5_CLIENTE,C5_CONDPAG" // _cTipo   $  "A/B"	// Chamado pelo Orcamento
	If cRisco $ "E"                                             /// MAURESI - AJUSTAR ESSA PARTE DO FONTE - 27/03/2019
	If Empty(M->C5_XAUTCC)
	M->C5_XSTATUS := "B"
	Else
	M->C5_XSTATUS := "C"
	EndIf
	Endif
	Endif
	*/
	
//If !SuperGetMV("MV_XANACRE")
//	_Retorno := .T.
EndIf

Return _Retorno

//������������������������������������������������������������������������������������������Ŀ
//�Usuarios que ir�o ter acesso ao campo AUT.CC no Pedido de Venda                           �
//� Validacao adicionada no X3_WHEN do campo C5_XAUTCC                                       �
//��������������������������������������������������������������������������������������������
User Function C5XAUTCC()

Local lRet	:= .F.
Local lCred := .f.

If SuperGetMV("MV_XANACRE") 
	If  ALTERA .and. __CUSERID $  SuperGETMV("MV_XCRDANA") //)"000000/000211" 
		lRet	:= .T.
	EndIf
EndIf
        
Return(lRet)


 
//������������������������������������������������������������������������������������������Ŀ
//�Usuarios que ir�o ter acesso a Cadastrar Condicao de Pagamento de Risco E                 �
//� Validacao adicionada no X3_WHEN do campo E4_XRISCOE e E4_CTRADT                          �
//��������������������������������������������������������������������������������������������
User Function E4RISCOE()

Local lRet	:= .F.
Local lCred := .f.

//If SuperGetMV("MV_XANACRE") 
	If  __CUSERID $  SuperGETMV("MV_XCRDANA") //)"000000/000211" 
		lRet	:= .T.
	EndIf
//EndIf
        
Return(lRet)

