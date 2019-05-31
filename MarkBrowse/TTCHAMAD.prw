#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} TTCHAMAD
Função chamada de Exemplo
@author Felipe Caiado
@since 27/05/2019
@version 1.0

@type Function
/*/
//-----------------------------------------------------------
User Function TTCHAMAD()

	Local aCampos as array
	Local aDados as array

	aCampos := {}

	aAdd( aCampos, { "NOME"		, "C", 030, 000, "Nome Cliente",, .T., "" } )
	aAdd( aCampos, { "ENDERECO"	, "C", 030, 000, "Endereço",, .T., "" } )
	aAdd( aCampos, { "VALOR"	, "N", 014, 002, "Valor","@E 999,999,999.99", .T., "" } )

	aDados := {}

	aAdd(aDados, {"NOME 01","RUA XXX",1000})
	aAdd(aDados, {"NOME 02","RUA YYY",2000})
	aAdd(aDados, {"TESTE 1","RUA ZZZ",3000})
	aAdd(aDados, {"TESTE 2","RUA TTT",4000})

	//Chamada da função de MarkBRowse
	U_TTMARKB(aCampos /*Campos*/, aDados/*Dados*/, .T./*Campo Totalizador?*/, "VALOR"/*Campo do Totalizado*/, .T./*Marcado?*/)

Return()

//-----------------------------------------------------------
/*/{Protheus.doc} TTMARKEX
Execlbock de retorno da função do MARKBROWSE
@author Felipe Caiado
@since 27/05/2019
@version 1.0

@type Function
/*/
//-----------------------------------------------------------
User Function TTMARKEX()

	Local cAliasPrc as character

	cAliasPrc := PARAMIXB[1]

	(cAliasPrc)->(DbGoTop())

	//Percore o alias do MarkBrowse
	While !(cAliasPrc)->(Eof())

		//Verifica os registros que foram marcados
		If !Empty((cAliasPrc)->MARK)

			Alert("Processar registro")

		EndIf

		(cAliasPrc)->(DbSkip())

	EndDo

Return()
