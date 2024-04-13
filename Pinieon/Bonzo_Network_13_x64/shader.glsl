#version 460 core
layout(location = 0) out vec4 outColor;
uniform float fGlobalTime;
uniform vec2 v2Resolution;
uniform float fFrameTime;
uniform sampler2D texPreviousFrame;
uniform sampler2D hjct;
uniform sampler2D pinieon;
#define resolution v2Resolution
#define time fGlobalTime
#define deltaTime fFrameTime
#define backbuffer texPreviousFrame
////////////////////////////
//........................//
//...%%........%%...%%%%..//
//..%%%.......%%.......%%.//
//...%%......%%.....%%%%..//
//...%%.....%%.....%%.....//
//.%%%%%%..%%......%%%%%%.//
//........................//
// DJ: Pinieon            //
// VJ: Renard             //
////////////////////////////
#define sat(x) clamp(x,0,1)
#define norm(x) normalize(x)
#define rep(i,n) for(int i=0;i<n;i++)
const float pi=acos(-1);
const float tau=2*pi;
vec3 hash(vec3 x){uvec3 v=floatBitsToUint(x);v=v*20240413u+1212121212u;v.x+=v.y*v.z;v.y+=v.z*v.x;v.z+=v.x*v.y;v^=v>>16u;v.x+=v.y*v.z;v.y+=v.z*v.x;v.z+=v.x*v.y;return vec3(v)/float(-1u);}
mat2 rot(float a){float s=sin(a),c=cos(a);return mat2(c,s,-s,c);}
mat3 bnt(vec3 T){T=norm(T);vec3 N=vec3(0,1,0);vec3 B=norm(cross(N,T));N=norm(cross(T,B));return mat3(B,N,T);}
float iplane(vec3 ro,vec3 rd,vec3 pd,float w){pd=norm(pd);float l=-(dot(ro,pd)+w)/dot(rd,pd);return (l<0?1e5:l);}
////////////////////////////
float bpm=144;
float alt,lt,tr,bt;
#define sc(x) hash(vec3(1.2,bt,x))
float fui(vec2 suv,float seed)
{
  float c=0;
  suv-=alt*.1;
  vec2 ruv=suv;
  rep(i,4)
  {
    if(hash(vec3(floor(ruv),i)).x<0.5)ruv*=2;
    else break;
  }
  vec3 h=hash(vec3(floor(ruv),2));
  vec2 fuv=(fract(ruv)*2-1)*rot(floor(h.y*4)*pi/4),auv=abs(fuv*2-1);
  
  float yo=sc(0).x;
  if(yo<.5)
    c=step(max(auv.x,auv.y),.5)*step(min(auv.x,auv.y),.1);
  else if(yo<.6)
    c=step(fract(dot(vec2(1),suv)),.1);
  else if(yo<.8)
    c=texture(hjct,suv).r;
  else
    c=texture(pinieon,suv).r;
  return c;
}
float march(vec3 ro,vec3 rd)
{
  float l=1e9;
  int n=16;
  float nya=sc(2).x;
  rep(i,n)
  {
    vec3 pd=norm(tan(hash(vec3(1,2+bt,i))*2-1));
    float w=2;
    if(nya<.4)
    {
      pd=vec3(0,0,1);w=i-n*0.5;
    }
    
    float d=iplane(ro,rd,pd,w);
    vec3 rp=rd*d+ro;
    vec2 uv=(pd.z*rp.xy+pd.y*rp.xz+pd.x*rp.zy)*0.5;
    if(0<fui(uv,w))l=min(l,d);
  }
  return l;
}

void main(void)
{
  vec2 fc=gl_FragCoord.xy,res=resolution;
  vec2 uv=fc/res,asp=res/min(res.x,res.y),asp2=res/max(res.x,res.y);
  float c=0;
  alt=lt=time*bpm/60;tr=fract(lt),bt=floor(lt);
  if(int(alt/4.)%2==0)
  {
    alt=lt=time*bpm/60/4.;tr=fract(lt),bt=floor(lt);
  }
  tr=1-exp(-tr*5);
  lt=tr+bt;
  vec2 suv=(uv*2-1)*asp;
  float ema=0.7;
  
  vec3 ro,dir;float z=1;
  if(sc(0).y<0.3)
  {
     ro=vec3(0,0,-5+tr*2);
     dir=-ro;
  }
  else if(sc(0).y<0.6)
  {
    ro=vec3(mix(-1,1,fract(alt)),0,-1);
    dir=vec3(0,0,1);
  }
  else
  {
    ro=vec3(cos(lt*0.2),0.2,sin(lt*.2))*5;
    dir=-ro;
  }
  z=mix(.3,2.,tr);
  vec3 rd=norm(bnt(dir)*vec3(suv,z));
  
  float l=march(ro,rd);
  vec3 rp=rd*l+ro;
  c+=exp(-.2*l)*step(0,l);
  //c=fui(suv,bt);//rnd
  
  vec3 back=texture(backbuffer,uv).rgb;
  
  vec3 col=mix(vec3(c,back.rg*mix(1.,1.5,step(sc(1).y,.5))),back,ema);
  col*=smoothstep(1.,.5,length(uv-0.5));
	outColor=vec4(col,1);
}