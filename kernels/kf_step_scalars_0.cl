__kernel void kf_step_scalars_0_kernel_main(__private parameters par,
                                            __read_only image3d_t bf_scalars_vc_a,
                                            __read_only image3d_t bf_momenta_fc_b,
                                            __read_only image3d_t bs_scalars_fc_x_0,
                                            __read_only image3d_t bs_scalars_fc_y_0,
                                            __read_only image3d_t bs_scalars_fc_z_0,
                                            __read_only image3d_t bRhs_mp_vc,
                                            __write_only image3d_t bf_scalars_vc_b)
{
  position pos = get_pos_bc(par, get_global_id(0), get_global_id(1), get_global_id(2));

  // ----------------------------------------------------------------- //
  // ice needs treatement, fields are already linked //
  // the integer in the kernel name is the stage //
  // kernel code is recycled for multiple scalar fields //
  // ----------------------------------------------------------------- //

  int s = 0;

  float4 z_new, mp;
  float4 fyn[1];
  float4 x_c[1], x_cr[1], y_c[1], y_cr[1], z_c[1], z_cr[1];

  x_c[0]  = read_f4(pos.x , pos.y , pos.z , bs_scalars_fc_x_0);
  x_cr[0] = read_f4(pos.xr, pos.y , pos.z , bs_scalars_fc_x_0);
  y_c[0]  = read_f4(pos.x , pos.y , pos.z , bs_scalars_fc_y_0);
  y_cr[0] = read_f4(pos.x , pos.yr, pos.z , bs_scalars_fc_y_0);
  z_c[0]  = read_f4(pos.x , pos.y , pos.z , bs_scalars_fc_z_0);
  z_cr[0] = read_f4(pos.x , pos.y , pos.zr, bs_scalars_fc_z_0);

  // u, v
  pos.ulf = read_imagef(bf_momenta_fc_b, (int4)(pos.x , pos.y , pos.z , 0)).x;
  pos.urf = read_imagef(bf_momenta_fc_b, (int4)(pos.xr, pos.y , pos.z , 0)).x;
  pos.vlf = read_imagef(bf_momenta_fc_b, (int4)(pos.x , pos.y , pos.z , 0)).y;
  pos.vrf = read_imagef(bf_momenta_fc_b, (int4)(pos.x , pos.yr, pos.z , 0)).y;
  pos.wlf = read_imagef(bf_momenta_fc_b, (int4)(pos.x , pos.y , pos.z , 0)).z;
  pos.wrf = read_imagef(bf_momenta_fc_b, (int4)(pos.x , pos.y , pos.zr, 0)).z;

  // fixed bc
  if (pos.s_xr==-1) pos.urf=0.0f;
  if (pos.s_xl==-1) pos.ulf=0.0f;
  if (pos.s_yr==-1) pos.vrf=0.0f;
  if (pos.s_yl==-1) pos.vlf=0.0f;
  if (pos.s_zr==-1) pos.wrf=0.0f;
  if (pos.s_zl==-1) pos.wlf=0.0f;

  float di = par.b[s][0] + par.b[s][1] + par.b[s][2];
  z_new = read_f4(pos.x, pos.y, pos.z, bf_scalars_vc_a);
  mp    = read_f4(pos.x, pos.y, pos.z, bRhs_mp_vc);

  central_dif(par, pos, &fyn[0], x_c[0], x_cr[0], y_c[0], y_cr[0], z_c[0], z_cr[0]);

  z_new += mp*par.dtis[s];
  z_new += par.b[s][0]*fyn[0]/di*par.dtis[s];               // 0,1,2

  write_f4(pos.x, pos.y, pos.z, z_new, bf_scalars_vc_b);
}
