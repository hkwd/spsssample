/*********************************************
 * OPL 22.1.0.0 Model
 * Author: IBM
 * Creation Date: 2023/01/06 at 11:46:08
 *********************************************/
//�@���m�̏��̒�`///////////////////////////////////////////////////////////////////////////
//�P���Ԗ��̓d�͎��v��
tuple TDemands{
  int time;
  float demand;
}

{TDemands}Demands=...;

float BatteryCapacity = 500;    //�~�d�r�̗e��
float ChargeDemandsEfficiency = 100;  //���Ԃ�����ɏ[���d�ł����
float BatteryInit = 0;    //�~�d�r�[�d�ʏ����l


//�A����ϐ��ƌ��莮///////////////////////////////////////////////////////////////////////////
//����ϐ�
dvar float BatteryInput[d in Demands];  //�[���d��

//���莮
dexpr float BatteryCharge[d in Demands] = BatteryInit + sum(d2 in Demands:d2.time<=d.time)BatteryInput[d2];  //�o�b�e���[�c��
dexpr float Consumption[d in Demands] = d.demand+ BatteryInput[d];      //�d�͏����
dexpr float MaxConsumption = max(d in Demands) Consumption[d];  //�d�͏���̍ő�l

//�B�ړI�֐��̒�`///////////////////////////////////////////////////////////////////////////
minimize MaxConsumption;//�d�͏�����ŏ�������

//�C��������̒�`///////////////////////////////////////////////////////////////////////////
subject to{
  forall(d in Demands){
    Consumption[d] >= 0;    //�d�͏���ʂ̓}�C�i�X�ɂȂ�Ȃ�
    BatteryCharge[d] <= BatteryCapacity;      //�o�b�e���[�e�ʈȏ�̓d�͂͏[�d�ł��Ȃ�
    if(d.time==1){                    //�o�b�e���[����̕��d�ʂ͏[�d����Ă���ʈȉ��ł���
      BatteryInput[d] >= -BatteryInit;    
    }else{
      BatteryInput[d] >= -BatteryCharge[item(Demands,d.time-1)];
    }  
    BatteryInput[d] <= ChargeDemandsEfficiency;    //�o�b�e���[�ւ̏[�d�ʂ͎��ԓ�������������
    BatteryInput[d] >= -ChargeDemandsEfficiency;    //�o�b�e���[����̕��d�ʂ͎��ԓ�������������  
  }
}