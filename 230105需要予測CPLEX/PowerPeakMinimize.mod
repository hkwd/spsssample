/*********************************************
 * OPL 22.1.0.0 Model
 * Author: IBM
 * Creation Date: 2023/01/06 at 11:46:08
 *********************************************/
//①既知の情報の定義///////////////////////////////////////////////////////////////////////////
//１時間毎の電力需要量
tuple TDemands{
  int time;
  float demand;
}

{TDemands}Demands=...;

float BatteryCapacity = 500;    //蓄電池の容量
float ChargeDemandsEfficiency = 100;  //時間あたりに充放電できる量
float BatteryInit = 0;    //蓄電池充電量初期値


//②決定変数と決定式///////////////////////////////////////////////////////////////////////////
//決定変数
dvar float BatteryInput[d in Demands];  //充放電量

//決定式
dexpr float BatteryCharge[d in Demands] = BatteryInit + sum(d2 in Demands:d2.time<=d.time)BatteryInput[d2];  //バッテリー残量
dexpr float Consumption[d in Demands] = d.demand+ BatteryInput[d];      //電力消費量
dexpr float MaxConsumption = max(d in Demands) Consumption[d];  //電力消費の最大値

//③目的関数の定義///////////////////////////////////////////////////////////////////////////
minimize MaxConsumption;//電力消費を最小化する

//④制約条件の定義///////////////////////////////////////////////////////////////////////////
subject to{
  forall(d in Demands){
    Consumption[d] >= 0;    //電力消費量はマイナスにならない
    BatteryCharge[d] <= BatteryCapacity;      //バッテリー容量以上の電力は充電できない
    if(d.time==1){                    //バッテリーからの放電量は充電されている量以下である
      BatteryInput[d] >= -BatteryInit;    
    }else{
      BatteryInput[d] >= -BatteryCharge[item(Demands,d.time-1)];
    }  
    BatteryInput[d] <= ChargeDemandsEfficiency;    //バッテリーへの充電量は時間当たり上限がある
    BatteryInput[d] >= -ChargeDemandsEfficiency;    //バッテリーからの放電量は時間当たり上限がある  
  }
}