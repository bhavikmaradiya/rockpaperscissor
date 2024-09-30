class FireStoreConfig {
  // user collection
  static const userCollection = 'users';
  static const userIdField = 'userId';
  static const userNameField = 'name';
  static const userEmailField = 'email';
  static const userWalletBalanceField = 'walletBalance';
  static const userFcmTokenField = 'fcmToken';

  //room collection
  static const roomCollection = 'rooms';
  static const roomIdField = 'roomId';
  static const roomIsAutoMatchField = 'isAutoMatch';
  static const roomInviteCodeField = 'inviteCode';
  static const roomStatusField = 'roomStatus';
  static const roomTypeField = 'roomType';
  static const roomWinnerIdField = 'roomWinnerId';
  static const roomCurrentRoundField = 'roomCurrentRound';
  static const roomTotalRoundsField = 'roomTotalRounds';
  static const roomHostIdField = 'roomHostId';
  static const roomTotalPotAmountField = 'roomTotalPotAmount';
  static const roomMinAmountToJoinField = 'roomMinAmountToJoin';
  static const roomPlayerIdsField = 'roomPlayerIds';
  static const roomPlayerIdsMapField = 'roomPlayerIdsMap';
  static const roomRoundInfoField = 'roomRoundInfo';

  //round info
  static const roundNoField = 'roundNo';
  static const player1IdField = 'player1Id';
  static const player2IdField = 'player2Id';
  static const player1MoveField = 'player1Move';
  static const player2MoveField = 'player2Move';
  static const roundWinnerIdField = 'roundWinnerId';

  //player moves collection
  static const playerMovesCollection = 'playerMoves';
  static const movesPlayer1IdField = 'player1Id';
  static const movesPlayer2IdField = 'player2Id';
  static const movesPlayer1MoveField = 'player1Move';
  static const movesPlayer2MoveField = 'player2Move';

  //quick play collection
  static const quickMatchCollection = 'quickPlay';
  static const quickMatchIdField = 'matchId';
  static const quickMatchPlayerIdField = 'playerId';
  static const quickMatchRoomIdField = 'roomId';
  static const quickMatchAmountField = 'totalAmount';
  static const quickMatchRoundsField = 'totalRounds';

  //transaction collection
  static const transactionCollection = "transaction";
  static const transactionIdField = 'transactionId';
  static const transactionUserIdField = 'transactionUserId';
  static const transactionRoomIdField = 'transactionRoomId';
  static const transactionTypeField = 'transactionType';
  static const transactionOpponentField = 'opponentName';
  static const transactionAmountField = 'transactionAmount';
  static const transactionPostWalletBalField = 'postWalletAmount';

  // General
  static const createdAtField = 'createdAt';
  static const expiresAtField = 'expiresAt';
  static const updatedAtField = 'updatedAt';
}
