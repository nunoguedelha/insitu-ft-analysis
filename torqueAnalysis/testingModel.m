
totalMass=0;
for j=3:7
  contactIndex=estimator.model.getLinkName(j)
link_h_skinFrame_temp=estimator.model.getFrameTransform(j);
link_h_skinFrame=link_h_skinFrame_temp.asAdjointTransformWrench.toMatlab();
    mass=estimator.model.getLink(j).inertia.getMass()
    totalMass=totalMass+mass
    
end
totalMass*9.81

% ft_h_rlowerl=[-0.0104501 9.58657e-05 0.999945 0.000101026 
% -0.999945 -1.00186e-06 -0.0104501 0.00966697 
% -5.11697e-14 -1 9.58709e-05 0.160225 
% 0 0 0 1 ]
% 
% trans=estimator.model.getFrameTransform(contactIndex);
% trans.asHomogeneousTransform.fromMatlab(ft_h_rlowerl)
% trans.inverse.asAdjointTransformWrench.toMatlab()
% trans.asAdjointTransformWrench.toMatlab()
% ft_r_lower=[-10.885498353964621,0.996306589030697,1.636417306408418,0.044155257660605,-2.300017203968768,0.038598018747963]
% 
% trans.inverse.asAdjointTransformWrench.toMatlab()*ft_r_lower'

%     'Model: 
%        Links: 
%          [0] root_link
%          [1] r_hip_1
%          [2] r_hip_2
%          [3] r_hip_3
%          [4] r_upper_leg
%          [5] r_lower_leg
%          [6] r_ankle_1
%          [7] r_ankle_2
%          [8] r_foot
%          [9] l_hip_1
%          [10] l_hip_2
%          [11] l_hip_3
%          [12] l_upper_leg
%          [13] l_lower_leg
%          [14] l_ankle_1
%          [15] l_ankle_2
%          [16] l_foot
%          [17] torso_1
%          [18] torso_2
%          [19] chest
%          [20] r_shoulder_1
%          [21] r_shoulder_2
%          [22] r_shoulder_3
%          [23] r_upper_arm
%          [24] r_elbow_1
%          [25] r_forearm
%          [26] r_wrist_1
%          [27] r_hand
%          [28] l_shoulder_1
%          [29] l_shoulder_2
%          [30] l_shoulder_3
%          [31] l_upper_arm
%          [32] l_elbow_1
%          [33] l_forearm
%          [34] l_wrist_1
%          [35] l_hand
%          [36] neck_1
%          [37] neck_2
%          [38] head
%        Frames: 
%          [39] r_lower_leg_dh_frame --> r_lower_leg
%          [40] r_lower_leg_skin_0 --> r_lower_leg
%          [41] r_lower_leg_skin_3 --> r_lower_leg
%          [42] r_lower_leg_skin_4 --> r_lower_leg
%          [43] r_lower_leg_skin_5 --> r_lower_leg
%          [44] r_lower_leg_skin_6 --> r_lower_leg
%          [45] r_lower_leg_skin_9 --> r_lower_leg
%          [46] r_lower_leg_skin_10 --> r_lower_leg
%          [47] r_lower_leg_skin_11 --> r_lower_leg
%          [48] r_lower_leg_skin_14 --> r_lower_leg
%          [49] r_lower_leg_skin_15 --> r_lower_leg
%          [50] r_lower_leg_skin_16 --> r_lower_leg
%          [51] r_lower_leg_skin_17 --> r_lower_leg
%          [52] r_lower_leg_skin_19 --> r_lower_leg
%          [53] r_lower_leg_skin_20 --> r_lower_leg
%          [54] r_lower_leg_skin_21 --> r_lower_leg
%          [55] r_lower_leg_skin_28 --> r_lower_leg
%          [56] r_lower_leg_skin_29 --> r_lower_leg
%          [57] r_lower_leg_skin_31 --> r_lower_leg
%          [58] r_lower_leg_skin_32 --> r_lower_leg
%          [59] r_lower_leg_skin_35 --> r_lower_leg
%          [60] r_lower_leg_skin_36 --> r_lower_leg
%          [61] r_lower_leg_skin_37 --> r_lower_leg
%          [62] r_lower_leg_skin_38 --> r_lower_leg
%          [63] r_lower_leg_skin_41 --> r_lower_leg
%          [64] r_lower_leg_skin_42 --> r_lower_leg
%          [65] r_lower_leg_skin_43 --> r_lower_leg
%          [66] r_lower_leg_skin_46 --> r_lower_leg
%          [67] r_lower_leg_skin_47 --> r_lower_leg
%          [68] r_lower_leg_skin_49 --> r_lower_leg
%          [69] r_lower_leg_skin_50 --> r_lower_leg
%          [70] r_lower_leg_skin_51 --> r_lower_leg
%          [71] r_lower_leg_skin_52 --> r_lower_leg
%          [72] r_lower_leg_skin_53 --> r_lower_leg
%          [73] r_lower_leg_skin_54 --> r_lower_leg
%          [74] r_lower_leg_skin_55 --> r_lower_leg
%          [75] r_lower_leg_skin_56 --> r_lower_leg
%          [76] r_lower_leg_skin_60 --> r_lower_leg
%          [77] r_lower_leg_skin_61 --> r_lower_leg
%          [78] r_sole --> r_foot
%          [79] l_sole --> l_foot
%          [80] r_forearm_skin_0 --> r_forearm
%          [81] r_forearm_skin_1 --> r_forearm
%          [82] r_forearm_skin_2 --> r_forearm
%          [83] r_forearm_skin_3 --> r_forearm
%          [84] r_forearm_skin_4 --> r_forearm
%          [85] r_forearm_skin_5 --> r_forearm
%          [86] r_forearm_skin_6 --> r_forearm
%          [87] r_forearm_skin_7 --> r_forearm
%          [88] r_forearm_skin_8 --> r_forearm
%          [89] r_forearm_skin_9 --> r_forearm
%          [90] r_forearm_skin_10 --> r_forearm
%          [91] r_forearm_skin_11 --> r_forearm
%          [92] r_forearm_skin_12 --> r_forearm
%          [93] r_forearm_skin_13 --> r_forearm
%          [94] r_forearm_skin_14 --> r_forearm
%          [95] r_forearm_skin_15 --> r_forearm
%          [96] r_forearm_skin_16 --> r_forearm
%          [97] r_forearm_skin_17 --> r_forearm
%          [98] r_forearm_skin_19 --> r_forearm
%          [99] r_forearm_skin_22 --> r_forearm
%          [100] r_forearm_skin_24 --> r_forearm
%          [101] r_forearm_skin_25 --> r_forearm
%          [102] r_forearm_skin_28 --> r_forearm
%          [103] r_forearm_skin_29 --> r_forearm
%          [104] r_forearm_dh_frame --> r_forearm
%          [105] r_hand_dh_frame --> r_hand
%          [106] l_forearm_skin_0 --> l_forearm
%          [107] l_forearm_skin_1 --> l_forearm
%          [108] l_forearm_skin_2 --> l_forearm
%          [109] l_forearm_skin_3 --> l_forearm
%          [110] l_forearm_skin_4 --> l_forearm
%          [111] l_forearm_skin_5 --> l_forearm
%          [112] l_forearm_skin_6 --> l_forearm
%          [113] l_forearm_skin_7 --> l_forearm
%          [114] l_forearm_skin_8 --> l_forearm
%          [115] l_forearm_skin_9 --> l_forearm
%          [116] l_forearm_skin_10 --> l_forearm
%          [117] l_forearm_skin_11 --> l_forearm
%          [118] l_forearm_skin_12 --> l_forearm
%          [119] l_forearm_skin_13 --> l_forearm
%          [120] l_forearm_skin_14 --> l_forearm
%          [121] l_forearm_skin_15 --> l_forearm
%          [122] l_forearm_skin_16 --> l_forearm
%          [123] l_forearm_skin_17 --> l_forearm
%          [124] l_forearm_skin_19 --> l_forearm
%          [125] l_forearm_skin_22 --> l_forearm
%          [126] l_forearm_skin_24 --> l_forearm
%          [127] l_forearm_skin_25 --> l_forearm
%          [128] l_forearm_skin_28 --> l_forearm
%          [129] l_forearm_skin_29 --> l_forearm
%          [130] l_forearm_dh_frame --> l_forearm
%          [131] l_hand_dh_frame --> l_hand
%          [132] imu_frame --> head
%          [133] base_link --> root_link
%          [134] l_foot_dh_frame --> l_foot
%          [135] r_foot_dh_frame --> r_foot
%          [136] l_leg_ft_sensor --> l_hip_3
%          [137] r_leg_ft_sensor --> r_hip_3
%          [138] l_foot_ft_sensor --> l_foot
%          [139] r_foot_ft_sensor --> r_foot
%          [140] l_arm_ft_sensor --> l_upper_arm
%          [141] r_arm_ft_sensor --> r_upper_arm
%          [142] head_imu_acc_1x1 --> head
%          [143] root_link_ems_acc_eb5 --> root_link
%          [144] chest_ems_acc_eb1 --> chest
%          [145] chest_ems_acc_eb2 --> chest
%          [146] chest_ems_acc_eb3 --> chest
%          [147] chest_ems_acc_eb4 --> chest
%          [148] chest_mtb_acc_0b7 --> chest
%          [149] chest_mtb_acc_0b8 --> chest
%          [150] chest_mtb_acc_0b9 --> chest
%          [151] chest_mtb_acc_0b10 --> chest
%          [152] r_upper_arm_mtb_acc_2b10 --> r_upper_arm
%          [153] r_upper_arm_mtb_acc_2b11 --> r_upper_arm
%          [154] r_upper_arm_mtb_acc_2b12 --> r_upper_arm
%          [155] r_upper_arm_mtb_acc_2b13 --> r_upper_arm
%          [156] r_forearm_mtb_acc_2b7 --> r_forearm
%          [157] r_forearm_mtb_acc_2b8 --> r_forearm
%          [158] r_forearm_mtb_acc_2b9 --> r_forearm
%          [159] l_upper_arm_mtb_acc_1b10 --> l_upper_arm
%          [160] l_upper_arm_mtb_acc_1b11 --> l_upper_arm
%          [161] l_upper_arm_mtb_acc_1b12 --> l_upper_arm
%          [162] l_upper_arm_mtb_acc_1b13 --> l_upper_arm
%          [163] l_forearm_mtb_acc_1b7 --> l_forearm
%          [164] l_forearm_mtb_acc_1b8 --> l_forearm
%          [165] l_forearm_mtb_acc_1b9 --> l_forearm
%          [166] r_upper_leg_ems_acc_eb8 --> r_upper_leg
%          [167] r_upper_leg_ems_acc_eb11 --> r_upper_leg
%          [168] r_upper_leg_mtb_acc_11b1 --> r_upper_leg
%          [169] r_upper_leg_mtb_acc_11b2 --> r_upper_leg
%          [170] r_upper_leg_mtb_acc_11b3 --> r_upper_leg
%          [171] r_upper_leg_mtb_acc_11b4 --> r_upper_leg
%          [172] r_upper_leg_mtb_acc_11b5 --> r_upper_leg
%          [173] r_upper_leg_mtb_acc_11b6 --> r_upper_leg
%          [174] r_upper_leg_mtb_acc_11b7 --> r_upper_leg
%          [175] r_lower_leg_ems_acc_eb9 --> r_lower_leg
%          [176] r_lower_leg_mtb_acc_11b8 --> r_lower_leg
%          [177] r_lower_leg_mtb_acc_11b9 --> r_lower_leg
%          [178] r_lower_leg_mtb_acc_11b10 --> r_lower_leg
%          [179] r_lower_leg_mtb_acc_11b11 --> r_lower_leg
%          [180] r_foot_mtb_acc_11b12 --> r_foot
%          [181] r_foot_mtb_acc_11b13 --> r_foot
%          [182] l_upper_leg_ems_acc_eb6 --> l_upper_leg
%          [183] l_upper_leg_ems_acc_eb10 --> l_upper_leg
%          [184] l_upper_leg_mtb_acc_10b1 --> l_upper_leg
%          [185] l_upper_leg_mtb_acc_10b2 --> l_upper_leg
%          [186] l_upper_leg_mtb_acc_10b3 --> l_upper_leg
%          [187] l_upper_leg_mtb_acc_10b4 --> l_upper_leg
%          [188] l_upper_leg_mtb_acc_10b5 --> l_upper_leg
%          [189] l_upper_leg_mtb_acc_10b6 --> l_upper_leg
%          [190] l_upper_leg_mtb_acc_10b7 --> l_upper_leg
%          [191] l_lower_leg_ems_acc_eb7 --> l_lower_leg
%          [192] l_lower_leg_mtb_acc_10b8 --> l_lower_leg
%          [193] l_lower_leg_mtb_acc_10b9 --> l_lower_leg
%          [194] l_lower_leg_mtb_acc_10b10 --> l_lower_leg
%          [195] l_lower_leg_mtb_acc_10b11 --> l_lower_leg
%          [196] l_foot_mtb_acc_10b12 --> l_foot
%          [197] l_foot_mtb_acc_10b13 --> l_foot
%          [198] root_link_ems_gyro_eb5 --> root_link
%          [199] chest_ems_gyro_eb1 --> chest
%          [200] chest_ems_gyro_eb2 --> chest
%          [201] chest_ems_gyro_eb3 --> chest
%          [202] chest_ems_gyro_eb4 --> chest
%          [203] r_upper_leg_ems_gyro_eb8 --> r_upper_leg
%          [204] r_upper_leg_ems_gyro_eb11 --> r_upper_leg
%          [205] r_lower_leg_ems_gyro_eb9 --> r_lower_leg
%          [206] l_upper_leg_ems_gyro_eb6 --> l_upper_leg
%          [207] l_upper_leg_ems_gyro_eb10 --> l_upper_leg
%          [208] l_lower_leg_ems_gyro_eb7 --> l_lower_leg
%        Joints: 
%          [0] r_hip_pitch (dofs: 1) : root_link<-->r_hip_1
%          [1] r_hip_roll (dofs: 1) : r_hip_1<-->r_hip_2
%          [2] r_hip_yaw (dofs: 1) : r_hip_3<-->r_upper_leg
%          [3] r_knee (dofs: 1) : r_upper_leg<-->r_lower_leg
%          [4] r_ankle_pitch (dofs: 1) : r_lower_leg<-->r_ankle_1
%          [5] r_ankle_roll (dofs: 1) : r_ankle_1<-->r_ankle_2
%          [6] l_hip_pitch (dofs: 1) : root_link<-->l_hip_1
%          [7] l_hip_roll (dofs: 1) : l_hip_1<-->l_hip_2
%          [8] l_hip_yaw (dofs: 1) : l_hip_3<-->l_upper_leg
%          [9] l_knee (dofs: 1) : l_upper_leg<-->l_lower_leg
%          [10] l_ankle_pitch (dofs: 1) : l_lower_leg<-->l_ankle_1
%          [11] l_ankle_roll (dofs: 1) : l_ankle_1<-->l_ankle_2
%          [12] torso_pitch (dofs: 1) : root_link<-->torso_1
%          [13] torso_roll (dofs: 1) : torso_1<-->torso_2
%          [14] torso_yaw (dofs: 1) : torso_2<-->chest
%          [15] r_shoulder_pitch (dofs: 1) : chest<-->r_shoulder_1
%          [16] r_shoulder_roll (dofs: 1) : r_shoulder_1<-->r_shoulder_2
%          [17] r_shoulder_yaw (dofs: 1) : r_shoulder_2<-->r_shoulder_3
%          [18] r_elbow (dofs: 1) : r_upper_arm<-->r_elbow_1
%          [19] r_wrist_prosup (dofs: 1) : r_elbow_1<-->r_forearm
%          [20] r_wrist_pitch (dofs: 1) : r_forearm<-->r_wrist_1
%          [21] r_wrist_yaw (dofs: 1) : r_wrist_1<-->r_hand
%          [22] l_shoulder_pitch (dofs: 1) : chest<-->l_shoulder_1
%          [23] l_shoulder_roll (dofs: 1) : l_shoulder_1<-->l_shoulder_2
%          [24] l_shoulder_yaw (dofs: 1) : l_shoulder_2<-->l_shoulder_3
%          [25] l_elbow (dofs: 1) : l_upper_arm<-->l_elbow_1
%          [26] l_wrist_prosup (dofs: 1) : l_elbow_1<-->l_forearm
%          [27] l_wrist_pitch (dofs: 1) : l_forearm<-->l_wrist_1
%          [28] l_wrist_yaw (dofs: 1) : l_wrist_1<-->l_hand
%          [29] neck_pitch (dofs: 1) : chest<-->neck_1
%          [30] neck_roll (dofs: 1) : neck_1<-->neck_2
%          [31] neck_yaw (dofs: 1) : neck_2<-->head
%          [32] r_leg_ft_sensor (dofs: 0) : r_hip_2<-->r_hip_3
%          [33] r_foot_ft_sensor (dofs: 0) : r_ankle_2<-->r_foot
%          [34] l_leg_ft_sensor (dofs: 0) : l_hip_2<-->l_hip_3
%          [35] l_foot_ft_sensor (dofs: 0) : l_ankle_2<-->l_foot
%          [36] r_arm_ft_sensor (dofs: 0) : r_shoulder_3<-->r_upper_arm
%          [37] l_arm_ft_sensor (dofs: 0) : l_shoulder_3<-->l_upper_arm
%      '