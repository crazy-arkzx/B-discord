/*
Essa Filterscript Connecta o Servidor com o Discord
E ja Vem com Alguns Comandos de Base

By: BO$$ (Editado e Traduzido Por: Crazy_ArKzX)
//--------------------------------[B-Discord]--------------------------------


#include <a_samp>
#include <bcolors>
#include <discord-connector>
#include <zcmd>
#include <foreach>
#include <sscanf>
#include <BCMD1>


#define serverconnect        "ID DO SEU CANAL AQUI"
#define playerconnect        "ID DO SEU CANAL AQUI"
#define playerdisconnect   "ID DO SEU CANAL AQUI"
#define commandlogs        "ID DO SEU CANAL AQUI"
#define playerchat               "ID DO SEU CANAL AQUI"
#define adminchannel        "ID DO SEU CANAL AQUI"
#define securitychannel     "ID DO SEU CANAL AQUI"

new stock                                   //
                                           /////////////////////////////////////////////
     DCC_Channel:Server_Connect,          // Quando Servidor Ligar  //
     DCC_Channel:Player_Connect,         // Quando Player Logar   /////////////////////////////////
     DCC_Channel:Player_Disconnect,     //Quando Player Deslogar //
     DCC_Channel:Command_Logs,         //Logs de Comandos         ////////////////////////
     DCC_Channel:Player_Chat,         //Chat dos Players         //
     DCC_Channel:Admin_Channel,      //Canal de Admin       ///////////////////////////////////
     DCC_Channel:Security_Channel   // Canal de Seguranca    //
                                   /////////////////////////////////////////////////
                                  //

;


forward DiscordSendLog(playerid,command[]);
forward DiscordSendLogTarget(playerid,command[],target);
stock DCC_SendChannelMessageFormatted( DCC_Channel: channel, const format[ ]) 
{
    #pragma unused channel
    #pragma unused format
    return 1;
}
stock PlayerName(playerid)
{
  new name[MAX_PLAYER_NAME];
  GetPlayerName(playerid, name, MAX_PLAYER_NAME);
  return name;
}
#define MAX_CLIENT_MSG_LENGTH 144

public OnFilterScriptInit()
{	
    Server_Connect = DCC_FindChannelById( serverconnect );

    Player_Connect = DCC_FindChannelById( playerconnect );

    Player_Disconnect = DCC_FindChannelById( playerdisconnect );

    Command_Logs = DCC_FindChannelById( commandlogs );

    Player_Chat = DCC_FindChannelById( playerchat );

    Admin_Channel = DCC_FindChannelById( adminchannel );

    Security_Channel = DCC_FindChannelById( securitychannel );
	

	new string[128],string2[128];
	format(string,sizeof (string),"Servidor Iniciado com Sucesso ");
	DCC_SendChannelMessage(Server_Connect,string);
	SetTimer("BotStatus", 1000, true);
    format(string2,sizeof (string2),"**Seu Servidor**");
    DCC_SendChannelMessage(Security_Channel,string2);
	return 1;

}

forward BotStatus(playerid);
public BotStatus(playerid)
{
    new iPlayers = Iter_Count(Player);
    new szBigString[1000];
    new count = 0;
    szBigString[ 0 ] = '\0';
    if ( iPlayers <= 30 )
        {
            foreach(new i : Player) 
            {
                if ( IsPlayerConnected( i ) ) 
                {
                    count++;

                }
            }
        }
    if(count == 0)
    {
        format( szBigString, sizeof( szBigString ), "Nao ha Ninguem Online .", count );
        DCC_SetBotActivity(szBigString);
        DCC_SetBotPresenceStatus(DCC_BotPresenceStatus:ONLINE);
    }
    if(count == 1)
    {
        format( szBigString, sizeof( szBigString ), "%d Player Online .", count );
        DCC_SetBotActivity(szBigString);
        DCC_SetBotPresenceStatus(DCC_BotPresenceStatus:IDLE);
    }
    if(count > 1)
    {
        format( szBigString, sizeof( szBigString ), "%d Player(s) Online.", count );
        DCC_SetBotActivity(szBigString);
        DCC_SetBotPresenceStatus(DCC_BotPresenceStatus:DO_NOT_DISTURB);
    }
}

public OnPlayerConnect(playerid)
{
    
    new pip[100],client1[24];
    GetPlayerIp(playerid, pip, sizeof(pip));
    GetPlayerVersion(playerid, client1, sizeof(client1));
    new string[250];
    format(string,sizeof (string),"**%s Entrou no Servidor.**",PlayerName(playerid));
    DCC_SendChannelMessage(Player_Connect,string);
    new str[2048],str2[100], footer[1024];
    format(str, sizeof(str), "Comandos");
    format(str2,sizeof (str2),"[Seguranca] {Player-Connected}\nPlayer Name - `%s`\nPlayer id - `%d`\nPlayer ip - `%s`\n**Client Version - `V%s` ",PlayerName(playerid),playerid,pip,client1);
    new DCC_Embed:embed = DCC_CreateEmbed(str, str2);
    DCC_SetEmbedColor(embed, 0xFF0000);
    format(footer, sizeof(footer), "Seu Servidor");
    DCC_SetEmbedFooter(embed, footer);
    DCC_SendChannelEmbedMessage(Security_Channel, embed);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{

    new string[250];
    format(string,sizeof (string),"**%s Saiu do Servidor**",PlayerName(playerid));
    DCC_SendChannelMessage(Player_Disconnect,string);
	return 1;
}
/*
forward DCC_OnMessageCreate(DCC_Message:message);
public DCC_OnMessageCreate(DCC_Message:message)
{
    new realMsg[100];
    DCC_GetMessageContent(message, realMsg, 100);
    new bool:IsBot;
    new DCC_Channel:channel;
    DCC_GetMessageChannel(message, channel);
    new DCC_User:author;
    DCC_GetMessageAuthor(message, author);
    DCC_IsUserBot(author, IsBot);
    if(channel == Player_Chat && !IsBot)
    {
        new user_name[32 + 1], str[152];
        DCC_GetUserName(author, user_name, 32);
        format(str,sizeof(str), "**{8a6cd1}[DISCORD] {aa1bb5}%s: {ffffff}%s**",user_name, realMsg);
        SendClientMessageToAll(-1, str);
    }
    return 1;
}
*/
public OnPlayerText(playerid, text[])
{

    new msg[128];
    format(msg, sizeof(msg), "```%s(%d): %s```", PlayerName(playerid), playerid, text);
    DCC_SendChannelMessage(Player_Chat, msg);
    return 1;
  
}
public OnRconLoginAttempt(ip[], password[], success)
{
    new playerid;
    if(!success)
    {
        new msg[250];
        format(msg, sizeof(msg),"**[Seguranca]**`%s` **Esta Tentando Logar na Rcon** | `%s`", PlayerName(playerid),password);
        DCC_SendChannelMessage(Security_Channel,msg);
    }
    if(success == 1)
    {
        new msg[128];
        format(msg, sizeof(msg),"[Seguranca]%s Logou na Rcon", PlayerName(playerid));
        DCC_SendChannelMessage(Security_Channel,msg);
    }
    return 1;
}
public OnRconCommand(cmd[])
{

    return 1;
}

/////////////////////////////COMANDOS//////////////////////COMANDOS///////////////////////////////////////////COMANDOS///////////////////////////////COMANDOS/////////
public OnDiscordCommandPerformed(DCC_User:user, DCC_Channel:channel, cmdtext[], success)
{
/*
    if(channel != Server_Connect || Player_Connect || Player_Disconnect || Command_Logs || Player_Chat || Admin_Channel || Security_Channel )
    {
        DCC_SendChannelMessage(channel, "[ERROR] Voce pode usar comandos B-Discord apenas em canais afetados pelo B-Discord");
    }
*/
    if(!success) {
    
        DCC_SendChannelMessage(channel, "[ERRO] **Esse Comando nao Existe!**");
    }

    return 1;
}
BCMD:info(user, channel, params[]) 
{
        new str[2048], footer[1024];
        format(str, sizeof(str), "SERVER INFO.");
        new DCC_Embed:embed = DCC_CreateEmbed(str, "IP - 123\nGamemode - \nMaxplayers -  \nLanguage - \nForum -  ");
        DCC_SetEmbedColor(embed, 0xFF0000);
        format(footer, sizeof(footer), "Seu Servidor");
        DCC_SetEmbedFooter(embed, footer);
        return DCC_SendChannelEmbedMessage(channel, embed);
    
}
BCMD:comandos(user, channel, params[]) 
{
        new str[2048], footer[1024];
        format(str, sizeof(str), "Comandos");
        new DCC_Embed:embed = DCC_CreateEmbed(str, "!info \n!players \n!creditos \n");
        DCC_SetEmbedColor(embed, 0xFF0000);
        format(footer, sizeof(footer), "Seu Servidor");
        DCC_SetEmbedFooter(embed, footer);
        return DCC_SendChannelEmbedMessage(channel, embed);
   
}

public DiscordSendLog(playerid,command[])
{
  new loggertext[128];
  format(loggertext,sizeof(loggertext),"```%s(%i) Usou o Comando: %s .```",PlayerName(playerid),playerid,command);
  return DCC_SendChannelMessage(Command_Logs, loggertext);
}
public DiscordSendLogTarget(playerid,command[],target)
{
  new loggertext[128];
  format(loggertext,sizeof(loggertext),"```%s(%i) Usou o Comando %s em %s(%i).```",PlayerName(playerid),playerid,command,PlayerName(target),target);
  DCC_SendChannelMessage(Command_Logs, loggertext);
}
BCMD:aa(user, channel, params[]) 
{
    if (channel == Admin_Channel) 
    {
        new str[2048], footer[1024];
        format(str, sizeof(str), "Comandos Admin");
        new DCC_Embed:embed = DCC_CreateEmbed(str, "\n!verinfo [id]\n!clear \n!tapa [id]\n!kick [id] \n!congelar [id] \n!descongelar [id] \n!ban [id] \n!GMX  \n !tempo \n!dargranaall [Quantidade]\n!setnivelall\n!explodir [id] " );
        format(footer, sizeof(footer), "Seu Servidor");
        DCC_SetEmbedFooter(embed, footer);
        return DCC_SendChannelEmbedMessage(channel, embed);
    }

    else DCC_SendChannelMessage(channel, "[ERRO] Voce nao e um Administrador." );
    
    return 1;
}


BCMD:players(user, channel, params[]) 
{
        new iPlayers = Iter_Count(Player);
        new count = 0;
        new szBigString[1000];
        szBigString[ 0 ] = '\0';
        if ( iPlayers <= 30 )
        {
        foreach(new i : Player) {
            if ( IsPlayerConnected( i ) ) {
                format( szBigString, sizeof( szBigString ), "%s%s (ID: %d)\n", szBigString, PlayerName( i ), i );
                count++;
            }
        }
        }
        format( szBigString, sizeof( szBigString ), "%s Há %d Jogador(es) Online.", szBigString, count );
        DCC_SendChannelMessage(channel,szBigString);
        //DCC_TriggerBotTypingIndicator(channel);
        return 1;
}
BCMD:say(user, channel, params[]) {

        if(isnull(params)) return DCC_SendChannelMessage(channel, "**USE: !say [msg]**");
        if(channel == Player_Chat)
        {
            new str[144], str1[144],username[33];
            DCC_GetUserName(user, username, sizeof(username));
            format(str, sizeof(str), "{8a6cd1}[DISCORD] {aa1bb5}%s: {ffffff}%s", username, params);
            SendClientMessageToAll(-1, str);
            format(str1, sizeof(str1), "```%s```",params);
            DCC_SendChannelMessage(channel, str1);
            return 1;
        }
        else return DCC_SendChannelMessage(channel, "[ERRO] Voce nao e um Administrador!");
}

//ADMINS 
SendClientMessage2(playerid, color, message[])
{
  if (strlen(message) <= MAX_CLIENT_MSG_LENGTH) {
    SendClientMessage(playerid, color, message);
  }
  else {
    new string[MAX_CLIENT_MSG_LENGTH + 1];
    strmid(string, message, 0, MAX_CLIENT_MSG_LENGTH);
    SendClientMessage(playerid, color, string);
  }
  return 1;
}

BCMD:congelar(user, channel, params[])
{
    if (channel != Admin_Channel) 
    {
      DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Admin!**");
      return 1;
    }
    new playerid;
    if(sscanf(params, "u", playerid))
        {
                    DCC_SendChannelMessage(Admin_Channel, "**USE: !Congelar [ID]**");
        }
    {
        if(IsPlayerConnected(playerid))
        {
            new msg[128];
            format(msg, sizeof(msg), "**[Congelafo] Voce foi Congelado!** ``%s.``", PlayerName(playerid));
            DCC_SendChannelMessage(Admin_Channel, msg);
            format(msg, sizeof(msg), "{FF0000}Voce {00CCCC}foi Congelado Por um {247A46}Administrador.");
            SendClientMessage2(playerid, 0xFF0000C8, msg);
            TogglePlayerControllable(playerid, 0);
        }
    }
    return 1;
}
BCMD:descongelar(user, channel, params[])
{
    new playerid;
    if (channel != Admin_Channel) 
    {
      DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
      return 1;
    }
    if(sscanf(params, "u", playerid))
        {
                    DCC_SendChannelMessage(Admin_Channel, "**USE: !Descongelar [ID]**");
                    return 1;
        }
    {

        if(IsPlayerConnected(playerid))
        {
            new msg[128];
            format(msg, sizeof(msg), "```[Descongelado]Voce foi Descongelado! %s.```", PlayerName(playerid));
            DCC_SendChannelMessage(Admin_Channel, msg);
            format(msg, sizeof(msg), "{FF0000}Voce {00CCCC} Foi Descongelado Pelo {247A46}Administrator.");
            SendClientMessage2(playerid, 0xFF0000C8, msg);
            TogglePlayerControllable(playerid, 1);
        }
    }
    return 1;
}
BCMD:kick(user, channel, params[])
{
    if (channel != Admin_Channel) 
        {
          DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
          return 1;
        }
    new targetid;
    if(IsPlayerConnected(targetid))
    {
        new string[125],string2[125];
        if(sscanf(params,"u",targetid)) return DCC_SendChannelMessage(channel,"**USE:/kick [ID]**");
        if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid)) return DCC_SendChannelMessage(channel," [ERRO] ID Invalido");
        format(string, sizeof(string), "SERVER:{FF0000} %s {00CCCC}Foi Kickado do Servidor por um {247A46}Administrator.", PlayerName(targetid));
        SendClientMessageToAll(COLOR_RED, string);
        format(string2, sizeof(string2), "```[Seu Servidor] Voce Kickou %s.```", PlayerName(targetid));
        DCC_SendChannelMessage(Admin_Channel, string2);
        Kick(targetid);
        return 1;
    }
    else return DCC_SendChannelMessage(Admin_Channel, "ID Nao Existe");

}
BCMD:tapa(user, channel, params[])
{
    new id, str2[128], Float:x, Float:y, Float:z;
    if (channel == Admin_Channel) 
    {
      if(sscanf(params, "u", id)) return DCC_SendChannelMessage(Admin_Channel, "**USE: !Tapa [ID]**");
      if(id == INVALID_PLAYER_ID || !IsPlayerConnected(id)) return  DCC_SendChannelMessage(channel," [ERRO] ID Invalido!");
      format(str2, sizeof(str2), "{FF0000}Voce {00CCCC} Levou um Tapa de um {247A46}Administrator.");
      SendClientMessageToAll(0x0000FFFF, str2);
      format(str2, sizeof(str2), "**[Seu Servidor] Voce deu um tapa em %s.**", PlayerName(id));
      DCC_SendChannelMessage(Admin_Channel, str2);
      GetPlayerPos(id, x, y, z);
      SetPlayerPos(id, x, y, z+10);
      return 1;
    }
    else return DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
}
BCMD:clear(user, channel, message[])
{
  if (channel != Admin_Channel) 
    {
      DCC_SendChannelMessage(channel, "**[ERROR] Voce nao e um Administrador!**");
      return 1;
    }
  {
  for( new i = 0; i <= 100; i ++ ) SendClientMessageToAll(COLOR_WHITE, "" );
  }
  new string[256];
  format(string, sizeof(string), "{247A46}*Administrator {FFFFFF} Limpou o Chat.");
  SendClientMessageToAll(COLOR_WHITE, string);
  format(string, sizeof(string), "**[CHAT] Voce Limpou o Chat.**");
  DCC_SendChannelMessage(Admin_Channel, string);
  #pragma unused message
  return 1;
}
BCMD:verinfo(user, channel, params[])
{
        if (channel != Admin_Channel) 
        {
            DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
            return 1;
        }
        new targetid;
        if(IsPlayerConnected(targetid))
        {

                new msg[600],  pIP[128], Float:health, Float:armour;
                if(sscanf(params, "u",  targetid)) return DCC_SendChannelMessage(Admin_Channel, "**USE: !verinfo [ID]**");
                if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid)) return DCC_SendChannelMessage(channel," [ERRO] ID Invalido!");
                GetPlayerIp(targetid, pIP, 128);
                GetPlayerHealth(targetid, health);
                GetPlayerArmour(targetid, armour);
                new ping;
                ping = GetPlayerPing(targetid);
                format(msg, sizeof(msg), "``%s``'s INFO: **IP**: ``%s`` | **Vida**: ``%d`` | **Arma**: ``%d`` | **Ping**: ``%i``", PlayerName(targetid), pIP, floatround(health), floatround(armour), ping);
                DCC_SendChannelMessage(Admin_Channel, msg);
                return 1;
        }
        else return  DCC_SendChannelMessage(channel, "[ERRO] Este Player nao Esta Conectado!");
}
BCMD:an(user, channel, params[])
{
  if (channel == Admin_Channel) 
    {
        new string[128];
        if(isnull(params)) return DCC_SendChannelMessage(Admin_Channel, "**USE: /an [Anuncio]**");
        format(string,sizeof(string),"{247A46}*Anuncio Discord: {00CCCC}%s",params);
        SendClientMessageToAll(COLOR_WHITE,string);
        DCC_SendChannelMessage(channel,"**Anuncio Enviado com Sucesso**");
        return 1;
    }
  else return DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador**!");
}
BCMD:ban(user, channel , params[])
{
    new msg[128],msg2[128],targetid;
    if(channel == Admin_Channel|| Security_Channel)
    {
        if(IsPlayerConnected(targetid))
        {
            if(sscanf(params, "u", targetid)) return DCC_SendChannelMessage(Admin_Channel, "**USE: !ban [ID]**");
            format(msg, sizeof(msg),"{00CCCC}%s Foi Banido Pelo Discord.", PlayerName(targetid));
            SendClientMessageToAll(COLOR_RED,msg);
            format(msg2, sizeof(msg2),"```[Seguranca] Voce Baniu o Jogador %s.```", PlayerName(targetid));
            DCC_SendChannelMessage(channel,msg2);
            Ban(targetid);
            return 1;
        }
        return 1;
        
    }
    else return DCC_SendChannelMessage(channel,"**[ERRO] Voce nao e um Administrador!**");
}
BCMD:creditos(user, channel, params[]) 
{
        DCC_SendChannelMessage(channel, "> **Dono do Servidor**\n> **Programador - Seu_Nome**" );
        return 1;
}
BCMD:gmx(user, channel , params[])
{
    if(channel == Admin_Channel || Security_Channel)
    {
        SendClientMessageToAll(COLOR_RED,"{00CCCC}GMX Iniciada por um {247A46}Administrator no Discord");
        DCC_SendChannelMessage(Admin_Channel,"**Servidor Reiniciando Sendo Reiniciado...**");
        SendRconCommand("gmx");
        return 1;
    }
    else return DCC_SendChannelMessage(channel,"**[ERRO] Voce nao e um Administrador!**");
}
BCMD:tempo(user, channel , params[])
{
        if (channel != Admin_Channel) 
        {
            DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
            return 1;
        }
        new string[125];
        new hour,minuite,second;
        gettime(hour,minuite,second);
        format(string, sizeof(string), "Tempo no Jogo: `%d:%d:%d`", hour, minuite, second);
        DCC_SendChannelMessage(Admin_Channel,string);
        return 1;
}

BCMD:dargranaall(user, channel , params[])
{
  for(new i = 0; i < MAX_PLAYERS; i ++)
  {
        if (channel != Admin_Channel) 
        {
            DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
            return 1;
        }
        new ammount;
        if(sscanf(params,"d", ammount)) return  DCC_SendChannelMessage(Admin_Channel,"**USE: !Dargranaall [Quantia]**");
        if(IsPlayerConnected(i))
        {
                GivePlayerMoney(i, ammount);
                new str[150],string[256];
                format(str, sizeof(str),"{247A46}Administrator {00CCCC}Deu R$%d Dinheiro Para Todos do Servidor.",ammount);
                SendClientMessageToAll(COLOR_ORANGE, str);
                format(string, sizeof(string), "**Todos os Jogadores Receberam R$%d de Dinheiro**",ammount);
                DCC_SendChannelMessage(Admin_Channel,string);
         }
  }
  return 1;
}
BCMD:setnivelall(user, channel , params[])
{
  for(new i = 0; i < MAX_PLAYERS; i ++)
  {
        if (channel != Admin_Channel) 
        {
            DCC_SendChannelMessage(channel, "****[ERRO] Voce nao e um Administrador!****");
            return 1;
        }
        new ammount;
        if(sscanf(params,"d", ammount)) return  DCC_SendChannelMessage(Admin_Channel,"**USE: /setnivelall [Nivel]**");
        if(IsPlayerConnected(i))
        {
                SetPlayerScore(i, GetPlayerScore(i)+ammount);
                new str[150],string[256];
                format(str, sizeof(str),"{247A46}Administrator {00CCCC}Setou %d Leveis Para Geral!",ammount);
                SendClientMessageToAll(COLOR_ORANGE, str);
                format(string, sizeof(string), "Todos os jogadores Receberam %d Leveis",ammount);
                DCC_SendChannelMessage(Admin_Channel,string);
         }
  }
  return 1;
}
BCMD:explodir(user, channel , params[])
{
          if (channel != Admin_Channel) 
          {
                DCC_SendChannelMessage(channel, "**[ERRO] Voce nao e um Administrador!**");
                return 1;
          }
          new player1, Float:x, Float:y, Float:z, str[70];
          if(sscanf(params,"d", player1)) return DCC_SendChannelMessage(Admin_Channel,"**USE: /explodir [ID]**");
          if(IsPlayerConnected(player1))
          {
                 GetPlayerPos(player1, x, y, z);
                 CreateExplosion(x, y, z, 7, 10.0);
                 format(str, sizeof(str),"```Voce Explodiu %s!```", PlayerName(player1));
                 DCC_SendChannelMessage(Admin_Channel,str);
                 SendClientMessage(player1,COLOR_RED, "{247A46}Administrator {00CCCC}Explodiu Voce!");
          }
                 else return DCC_SendChannelMessage(Admin_Channel,"Este Player nao Esta Conectado!");
          return 1;
}