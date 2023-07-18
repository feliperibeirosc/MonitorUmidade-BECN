# <img src="https://i.imgur.com/pR8ORwo.png" width="50" /> Monitor de Umidade - APP
> Aplicativo foi feito para o projeto de "Programação de um sistema de alerta para deslizamentos baseados em Arduino" da disciplina de BECN da UFABC

## Sobre o APP
Esse aplicativo representa uma prova do conceito de um sistema de prevenção de deslizamentos, esse sistema realizaria o monitoramento remoto da umidade do solo de certo local, e caso essa umidade ultrapasse um certo valor, uma notificação push seria enviada para os usuários do aplicativo alertando acerca do risco de deslizamento.

No caso deste projeto, como exemplo do sistema de monitoramento foi feito um [projeto usando Arduino](https://github.com/GabrielFrigo4/ArduinoUFABC) que mede a umidade da terra com um sensor de umidade do solo (Higrômetro), envia essa informação para outro Arduino usando rádio frequência, que por fim, envia as informações para uma Realtime Database do Firebase. **Esse aplicativo é a representação do aplicativo que receberia a notificação push acerca do risco de deslizamento.**

## Funcionalidades
- Visualização dos dados dos sensores de umidade disponíveis na Realtime Database, exibindo a média dos dados 
- Edição do valor máximo de umidade, valor utilizado para emitir os alertas de deslizamento
- Cadastra o dispositivo e recebe notificações emitidas pelo Firebase Cloud Messaging (FCM), mesmo com o app fechado

## Screenshots

<table> 
  <tr>
    <td> 
      <img width="250" src="https://i.imgur.com/5qXJ7z0.jpg"> </img>
    </td>
    <td>
      <img width="250" src="https://i.imgur.com/qNPWfkz.jpg"> </img> 
    </td>
    <td> 
        <img width="250" src="https://i.imgur.com/w8t6vMI.jpg"> </img>
    </td>
  </tr>
  
  <tr>
     <td>
       <img width="250" src="https://i.imgur.com/ksrihM9.jpg"> </img>
    </td>
  </tr>
</table>
