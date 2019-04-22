       subroutine advance(px,py,u,v,dx,dy,dt,nx,ny,np)
       implicit none 
!      import/export
       integer(kind=4)                 ,intent(in)   :: nx,ny
       integer(kind=4)                 ,intent(in)   :: np
       real(kind=8)   ,dimension(ny,nx),intent(in)   :: u,v
       real(kind=8)   ,dimension(np)   ,intent(inout):: px,py
       real(kind=8)                    ,intent(in)   :: dx,dy,dt
!      local
       integer(kind=4) :: ip,i,j
       real(kind=8)   ,dimension(2,2) :: w
       real(kind=8)                   :: fcx,fcy,pu,pv,dxi,dyi

!f2py intent(in)   u,v
!f2py intent(inout) px,py
!f2py intent(in)   dx,dy,dt
!f2py intent(in)   nx,ny
!f2py intent(in)   nxg,nyg
!f2py intent(in)   i0,j0
!f2py intent(in)   np

       dxi  = 1/dx
       dyi  = 1/dy

       do ip = 1,np
         if (isnan(px(ip)) ) then
c           print *,ip,' is nan'
         else
           i = floor(px(ip))
           j = floor(py(ip))
           fcx = px(ip) -i
           fcy = py(ip) -j
           w(1,1) = (1-fcx)*(1-fcy)    ! weight for i,j
           w(1,2) = fcx*(1-fcy);       ! weight for i+1,j
           w(2,2) = fcx*fcy;           ! weight for i+1,j+1
           w(2,1) = (1-fcx)*fcy;       ! weight for i,j+1
           pu   = sum(u(j:j+1,i:i+1)*w)
           pv   = sum(v(j:j+1,i:i+1)*w)
           px(ip) = px(ip) + dt*pu*dxi
           py(ip) = py(ip) + dt*pv*dyi
         endif
       enddo
!
       end
!----------------------------------------------------------------------------------------------
       subroutine seed(px,py,npmx,mask,nx,ny,np)
       implicit none 
!      import/export
       integer(kind=4)                 ,intent(in)   :: nx,ny
       integer(kind=4)                 ,intent(in)   :: np
       integer(kind=4),dimension(ny,nx),intent(in)   :: mask
       real(kind=8)   ,dimension(np)   ,intent(inout):: px,py
       integer(kind=4)                 ,intent(inout):: npmx
!      local
       integer(kind=4) :: ip,i,j,id
       integer(kind=4),allocatable,dimension(:,:) :: grid

!f2py intent(inout) px,py
!f2py intent(in)    mask
!f2py intent(inout) npmx
!f2py intent(in)    nx,ny
!f2py intent(in)    npparticles.f90

!      print *,'fo: ',npmx
       allocate(grid(nx,ny))
       grid = 0

       !! find empty cells
       do ip = 1,npmx  !! max particle index that is currently used
          i = floor(px(ip))
          j = floor(py(ip))
          grid(j,i) = 1
       enddo
!
!      empty cells in the mask will get a new particle
       id = 1
       do j = 1,ny
         do i = 1,nx
           if (mask(j,i).eq.1.and.grid(j,i).eq.0) then
             !! grab a particle from inbetween, if available
             do ip = id,npmx 
               if ( isnan(px(ip)) ) then
                 print * ,'found one'
                 px(ip) = i
                 py(ip) = j
                 grid(j,i) = 1
                 exit
               endif
             enddo
             !! grab a particle from the end
             if (grid(j,i).eq.0.and.npmx.lt.np) then
               npmx = npmx + 1
               ip = npmx
               px(npmx) = i
               py(npmx) = j
             endif
           endif
        enddo
       enddo
       deallocate(grid)
!      print *,'fo: ',npmx

*particles.f90
       end
!---------------------------------------------------------------------------------particles.f90-------------
