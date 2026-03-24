    
    
CREATE PROCEDURE [reports].[USP_REL_CONSISTENCIAS_CHANGE_X_EBANK] (@DATA DATETIME)    
AS    
-- =============================================     
-- Author:  Mariano Magri    
-- Create date:   11/02/2020    
-- Description:  A20 01 07850Criar relatório de consistência    
--*** Histórico de Alterações *****************************     
--    Item                       Data        Analista                    Descrição     
--    #01#                                     11/02/2020    Mayara de Oliveira               Criação do Report              
-- =============================================    
BEGIN    
       SET NOCOUNT ON    
       SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
               
   -- DECLARE @DATA                   DATETIME    
    
--cria temporária    
create table #inconsistencias (    
   Regra varchar(40),    
   Data varchar(15),    
   Registro varchar(20),    
   Titular varchar(50),    
   Nome varchar(200),    
   Nat char(1),    
   ValorMN money,    
   Conta varchar(50),    
   Documento varchar(20),    
   Historico varchar(100),    
   OpVinculadas varchar(20),    
   Tesouraria int    
)    
    
insert into #inconsistencias    
Select     
      'Contém Change / Não contém e-Bank'      Regra,    
         convert(varchar,c4.DATA,103)             Data,    
         c4.REGISTRO                              Registro,     
         c4.TITULARN                              TitularRN,     
         CAMBIO..db01.NOME                                Nome,     
      Case when c4.valormn > '0'     
              then 'C' else 'D' End               DC,     
         c4.VALORMN                               ValorMN,     
      Case when c4.CONTACC <> ''     
              then c4.CONTACC else CAMBIO..db01.conta End Conta_CC,     
      right(c4.REGISTRO,7)                     Documento,      
      c4.HISTORICO                             Historico,     
         c4.OPVINCULA5                            OpVinculadas,    
    
         (Select isnull(count(1),0)    
            from agenciaw..movto m    
        Where m.datamovto = c4.data    
               and m.sisorigem = 'CHANGE'     
               and m.nrodocto =  right(c4.REGISTRO,7)    
               and m.status <> 'E') Tesouraria    
    
from CAMBIO..CL04 c4 with (nolock)    
      Inner Join CAMBIO..db01 with (nolock) on (c4.TITULARN = CAMBIO..db01.codigo)    
Where c4.CONTA ='15240000000' --fixo    
  and c4.DATA= @DATA --trocar por parâmetro    
  and c4.FORMAMN='CC'     
  and c4.LOTE ='1'     
    
insert into #inconsistencias    
Select 'Contém e-Bank / Não contém Change'         Regra,    
        convert(varchar,m.datamovto,103)            Data,    
             0                                           Registro,    
             0                                           Titular,    
             ''                                          Nome,    
             m.natureza                                  Nat,    
             m.valor                                     ValorMN,    
             m.codagencia + ' ' + m.nroconta             Conta,    
             m.nrodocto                                  Documento,    
             ''                                          Historio,    
             ''                                          OpVincluadas,    
    
             (Select count(1)    
           from CAMBIO..cl04 c4 with (nolock)    
          Where c4.data = m.datamovto    
                 and c4.CONTA ='15240000000'     
            and c4.FORMAMN='CC'     
            and c4.LOTE ='1'    
                    and right(c4.registro,7) = m.nrodocto) Tesouraria    
    
  from agenciaw..Movto m with (nolock)    
Where m.datamovto = @DATA --trocar por parâmetro    
   and m.sisorigem = 'CHANGE' --fixo    
   and m.status <> 'E' --fixo    
    
Select * from #inconsistencias    
where Tesouraria <> 1;    
    
end 