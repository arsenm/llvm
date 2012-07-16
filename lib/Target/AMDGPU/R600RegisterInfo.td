
class R600Reg <string name, bits<16> encoding> : Register<name> {
  let Namespace = "AMDGPU";
  let HWEncoding = encoding;
}

class R600Reg_128<string n, list<Register> subregs, bits<16> encoding> :
    RegisterWithSubRegs<n, subregs> {
  let Namespace = "AMDGPU";
  let SubRegIndices = [sel_x, sel_y, sel_z, sel_w];
  let HWEncoding = encoding;
}

def C0_X : R600Reg <"C0.X", 0>;
def C0_Y : R600Reg <"C0.Y", 0>;
def C0_Z : R600Reg <"C0.Z", 0>;
def C0_W : R600Reg <"C0.W", 0>;
def C1_X : R600Reg <"C1.X", 1>;
def C1_Y : R600Reg <"C1.Y", 1>;
def C1_Z : R600Reg <"C1.Z", 1>;
def C1_W : R600Reg <"C1.W", 1>;
def C2_X : R600Reg <"C2.X", 2>;
def C2_Y : R600Reg <"C2.Y", 2>;
def C2_Z : R600Reg <"C2.Z", 2>;
def C2_W : R600Reg <"C2.W", 2>;
def C3_X : R600Reg <"C3.X", 3>;
def C3_Y : R600Reg <"C3.Y", 3>;
def C3_Z : R600Reg <"C3.Z", 3>;
def C3_W : R600Reg <"C3.W", 3>;
def C4_X : R600Reg <"C4.X", 4>;
def C4_Y : R600Reg <"C4.Y", 4>;
def C4_Z : R600Reg <"C4.Z", 4>;
def C4_W : R600Reg <"C4.W", 4>;
def C5_X : R600Reg <"C5.X", 5>;
def C5_Y : R600Reg <"C5.Y", 5>;
def C5_Z : R600Reg <"C5.Z", 5>;
def C5_W : R600Reg <"C5.W", 5>;
def C6_X : R600Reg <"C6.X", 6>;
def C6_Y : R600Reg <"C6.Y", 6>;
def C6_Z : R600Reg <"C6.Z", 6>;
def C6_W : R600Reg <"C6.W", 6>;
def C7_X : R600Reg <"C7.X", 7>;
def C7_Y : R600Reg <"C7.Y", 7>;
def C7_Z : R600Reg <"C7.Z", 7>;
def C7_W : R600Reg <"C7.W", 7>;
def C8_X : R600Reg <"C8.X", 8>;
def C8_Y : R600Reg <"C8.Y", 8>;
def C8_Z : R600Reg <"C8.Z", 8>;
def C8_W : R600Reg <"C8.W", 8>;
def C9_X : R600Reg <"C9.X", 9>;
def C9_Y : R600Reg <"C9.Y", 9>;
def C9_Z : R600Reg <"C9.Z", 9>;
def C9_W : R600Reg <"C9.W", 9>;
def C10_X : R600Reg <"C10.X", 10>;
def C10_Y : R600Reg <"C10.Y", 10>;
def C10_Z : R600Reg <"C10.Z", 10>;
def C10_W : R600Reg <"C10.W", 10>;
def C11_X : R600Reg <"C11.X", 11>;
def C11_Y : R600Reg <"C11.Y", 11>;
def C11_Z : R600Reg <"C11.Z", 11>;
def C11_W : R600Reg <"C11.W", 11>;
def C12_X : R600Reg <"C12.X", 12>;
def C12_Y : R600Reg <"C12.Y", 12>;
def C12_Z : R600Reg <"C12.Z", 12>;
def C12_W : R600Reg <"C12.W", 12>;
def C13_X : R600Reg <"C13.X", 13>;
def C13_Y : R600Reg <"C13.Y", 13>;
def C13_Z : R600Reg <"C13.Z", 13>;
def C13_W : R600Reg <"C13.W", 13>;
def C14_X : R600Reg <"C14.X", 14>;
def C14_Y : R600Reg <"C14.Y", 14>;
def C14_Z : R600Reg <"C14.Z", 14>;
def C14_W : R600Reg <"C14.W", 14>;
def C15_X : R600Reg <"C15.X", 15>;
def C15_Y : R600Reg <"C15.Y", 15>;
def C15_Z : R600Reg <"C15.Z", 15>;
def C15_W : R600Reg <"C15.W", 15>;
def C16_X : R600Reg <"C16.X", 16>;
def C16_Y : R600Reg <"C16.Y", 16>;
def C16_Z : R600Reg <"C16.Z", 16>;
def C16_W : R600Reg <"C16.W", 16>;
def C17_X : R600Reg <"C17.X", 17>;
def C17_Y : R600Reg <"C17.Y", 17>;
def C17_Z : R600Reg <"C17.Z", 17>;
def C17_W : R600Reg <"C17.W", 17>;
def C18_X : R600Reg <"C18.X", 18>;
def C18_Y : R600Reg <"C18.Y", 18>;
def C18_Z : R600Reg <"C18.Z", 18>;
def C18_W : R600Reg <"C18.W", 18>;
def C19_X : R600Reg <"C19.X", 19>;
def C19_Y : R600Reg <"C19.Y", 19>;
def C19_Z : R600Reg <"C19.Z", 19>;
def C19_W : R600Reg <"C19.W", 19>;
def C20_X : R600Reg <"C20.X", 20>;
def C20_Y : R600Reg <"C20.Y", 20>;
def C20_Z : R600Reg <"C20.Z", 20>;
def C20_W : R600Reg <"C20.W", 20>;
def C21_X : R600Reg <"C21.X", 21>;
def C21_Y : R600Reg <"C21.Y", 21>;
def C21_Z : R600Reg <"C21.Z", 21>;
def C21_W : R600Reg <"C21.W", 21>;
def C22_X : R600Reg <"C22.X", 22>;
def C22_Y : R600Reg <"C22.Y", 22>;
def C22_Z : R600Reg <"C22.Z", 22>;
def C22_W : R600Reg <"C22.W", 22>;
def C23_X : R600Reg <"C23.X", 23>;
def C23_Y : R600Reg <"C23.Y", 23>;
def C23_Z : R600Reg <"C23.Z", 23>;
def C23_W : R600Reg <"C23.W", 23>;
def C24_X : R600Reg <"C24.X", 24>;
def C24_Y : R600Reg <"C24.Y", 24>;
def C24_Z : R600Reg <"C24.Z", 24>;
def C24_W : R600Reg <"C24.W", 24>;
def C25_X : R600Reg <"C25.X", 25>;
def C25_Y : R600Reg <"C25.Y", 25>;
def C25_Z : R600Reg <"C25.Z", 25>;
def C25_W : R600Reg <"C25.W", 25>;
def C26_X : R600Reg <"C26.X", 26>;
def C26_Y : R600Reg <"C26.Y", 26>;
def C26_Z : R600Reg <"C26.Z", 26>;
def C26_W : R600Reg <"C26.W", 26>;
def C27_X : R600Reg <"C27.X", 27>;
def C27_Y : R600Reg <"C27.Y", 27>;
def C27_Z : R600Reg <"C27.Z", 27>;
def C27_W : R600Reg <"C27.W", 27>;
def C28_X : R600Reg <"C28.X", 28>;
def C28_Y : R600Reg <"C28.Y", 28>;
def C28_Z : R600Reg <"C28.Z", 28>;
def C28_W : R600Reg <"C28.W", 28>;
def C29_X : R600Reg <"C29.X", 29>;
def C29_Y : R600Reg <"C29.Y", 29>;
def C29_Z : R600Reg <"C29.Z", 29>;
def C29_W : R600Reg <"C29.W", 29>;
def C30_X : R600Reg <"C30.X", 30>;
def C30_Y : R600Reg <"C30.Y", 30>;
def C30_Z : R600Reg <"C30.Z", 30>;
def C30_W : R600Reg <"C30.W", 30>;
def C31_X : R600Reg <"C31.X", 31>;
def C31_Y : R600Reg <"C31.Y", 31>;
def C31_Z : R600Reg <"C31.Z", 31>;
def C31_W : R600Reg <"C31.W", 31>;
def C32_X : R600Reg <"C32.X", 32>;
def C32_Y : R600Reg <"C32.Y", 32>;
def C32_Z : R600Reg <"C32.Z", 32>;
def C32_W : R600Reg <"C32.W", 32>;
def C33_X : R600Reg <"C33.X", 33>;
def C33_Y : R600Reg <"C33.Y", 33>;
def C33_Z : R600Reg <"C33.Z", 33>;
def C33_W : R600Reg <"C33.W", 33>;
def C34_X : R600Reg <"C34.X", 34>;
def C34_Y : R600Reg <"C34.Y", 34>;
def C34_Z : R600Reg <"C34.Z", 34>;
def C34_W : R600Reg <"C34.W", 34>;
def C35_X : R600Reg <"C35.X", 35>;
def C35_Y : R600Reg <"C35.Y", 35>;
def C35_Z : R600Reg <"C35.Z", 35>;
def C35_W : R600Reg <"C35.W", 35>;
def C36_X : R600Reg <"C36.X", 36>;
def C36_Y : R600Reg <"C36.Y", 36>;
def C36_Z : R600Reg <"C36.Z", 36>;
def C36_W : R600Reg <"C36.W", 36>;
def C37_X : R600Reg <"C37.X", 37>;
def C37_Y : R600Reg <"C37.Y", 37>;
def C37_Z : R600Reg <"C37.Z", 37>;
def C37_W : R600Reg <"C37.W", 37>;
def C38_X : R600Reg <"C38.X", 38>;
def C38_Y : R600Reg <"C38.Y", 38>;
def C38_Z : R600Reg <"C38.Z", 38>;
def C38_W : R600Reg <"C38.W", 38>;
def C39_X : R600Reg <"C39.X", 39>;
def C39_Y : R600Reg <"C39.Y", 39>;
def C39_Z : R600Reg <"C39.Z", 39>;
def C39_W : R600Reg <"C39.W", 39>;
def C40_X : R600Reg <"C40.X", 40>;
def C40_Y : R600Reg <"C40.Y", 40>;
def C40_Z : R600Reg <"C40.Z", 40>;
def C40_W : R600Reg <"C40.W", 40>;
def C41_X : R600Reg <"C41.X", 41>;
def C41_Y : R600Reg <"C41.Y", 41>;
def C41_Z : R600Reg <"C41.Z", 41>;
def C41_W : R600Reg <"C41.W", 41>;
def C42_X : R600Reg <"C42.X", 42>;
def C42_Y : R600Reg <"C42.Y", 42>;
def C42_Z : R600Reg <"C42.Z", 42>;
def C42_W : R600Reg <"C42.W", 42>;
def C43_X : R600Reg <"C43.X", 43>;
def C43_Y : R600Reg <"C43.Y", 43>;
def C43_Z : R600Reg <"C43.Z", 43>;
def C43_W : R600Reg <"C43.W", 43>;
def C44_X : R600Reg <"C44.X", 44>;
def C44_Y : R600Reg <"C44.Y", 44>;
def C44_Z : R600Reg <"C44.Z", 44>;
def C44_W : R600Reg <"C44.W", 44>;
def C45_X : R600Reg <"C45.X", 45>;
def C45_Y : R600Reg <"C45.Y", 45>;
def C45_Z : R600Reg <"C45.Z", 45>;
def C45_W : R600Reg <"C45.W", 45>;
def C46_X : R600Reg <"C46.X", 46>;
def C46_Y : R600Reg <"C46.Y", 46>;
def C46_Z : R600Reg <"C46.Z", 46>;
def C46_W : R600Reg <"C46.W", 46>;
def C47_X : R600Reg <"C47.X", 47>;
def C47_Y : R600Reg <"C47.Y", 47>;
def C47_Z : R600Reg <"C47.Z", 47>;
def C47_W : R600Reg <"C47.W", 47>;
def C48_X : R600Reg <"C48.X", 48>;
def C48_Y : R600Reg <"C48.Y", 48>;
def C48_Z : R600Reg <"C48.Z", 48>;
def C48_W : R600Reg <"C48.W", 48>;
def C49_X : R600Reg <"C49.X", 49>;
def C49_Y : R600Reg <"C49.Y", 49>;
def C49_Z : R600Reg <"C49.Z", 49>;
def C49_W : R600Reg <"C49.W", 49>;
def C50_X : R600Reg <"C50.X", 50>;
def C50_Y : R600Reg <"C50.Y", 50>;
def C50_Z : R600Reg <"C50.Z", 50>;
def C50_W : R600Reg <"C50.W", 50>;
def C51_X : R600Reg <"C51.X", 51>;
def C51_Y : R600Reg <"C51.Y", 51>;
def C51_Z : R600Reg <"C51.Z", 51>;
def C51_W : R600Reg <"C51.W", 51>;
def C52_X : R600Reg <"C52.X", 52>;
def C52_Y : R600Reg <"C52.Y", 52>;
def C52_Z : R600Reg <"C52.Z", 52>;
def C52_W : R600Reg <"C52.W", 52>;
def C53_X : R600Reg <"C53.X", 53>;
def C53_Y : R600Reg <"C53.Y", 53>;
def C53_Z : R600Reg <"C53.Z", 53>;
def C53_W : R600Reg <"C53.W", 53>;
def C54_X : R600Reg <"C54.X", 54>;
def C54_Y : R600Reg <"C54.Y", 54>;
def C54_Z : R600Reg <"C54.Z", 54>;
def C54_W : R600Reg <"C54.W", 54>;
def C55_X : R600Reg <"C55.X", 55>;
def C55_Y : R600Reg <"C55.Y", 55>;
def C55_Z : R600Reg <"C55.Z", 55>;
def C55_W : R600Reg <"C55.W", 55>;
def C56_X : R600Reg <"C56.X", 56>;
def C56_Y : R600Reg <"C56.Y", 56>;
def C56_Z : R600Reg <"C56.Z", 56>;
def C56_W : R600Reg <"C56.W", 56>;
def C57_X : R600Reg <"C57.X", 57>;
def C57_Y : R600Reg <"C57.Y", 57>;
def C57_Z : R600Reg <"C57.Z", 57>;
def C57_W : R600Reg <"C57.W", 57>;
def C58_X : R600Reg <"C58.X", 58>;
def C58_Y : R600Reg <"C58.Y", 58>;
def C58_Z : R600Reg <"C58.Z", 58>;
def C58_W : R600Reg <"C58.W", 58>;
def C59_X : R600Reg <"C59.X", 59>;
def C59_Y : R600Reg <"C59.Y", 59>;
def C59_Z : R600Reg <"C59.Z", 59>;
def C59_W : R600Reg <"C59.W", 59>;
def C60_X : R600Reg <"C60.X", 60>;
def C60_Y : R600Reg <"C60.Y", 60>;
def C60_Z : R600Reg <"C60.Z", 60>;
def C60_W : R600Reg <"C60.W", 60>;
def C61_X : R600Reg <"C61.X", 61>;
def C61_Y : R600Reg <"C61.Y", 61>;
def C61_Z : R600Reg <"C61.Z", 61>;
def C61_W : R600Reg <"C61.W", 61>;
def C62_X : R600Reg <"C62.X", 62>;
def C62_Y : R600Reg <"C62.Y", 62>;
def C62_Z : R600Reg <"C62.Z", 62>;
def C62_W : R600Reg <"C62.W", 62>;
def C63_X : R600Reg <"C63.X", 63>;
def C63_Y : R600Reg <"C63.Y", 63>;
def C63_Z : R600Reg <"C63.Z", 63>;
def C63_W : R600Reg <"C63.W", 63>;
def C64_X : R600Reg <"C64.X", 64>;
def C64_Y : R600Reg <"C64.Y", 64>;
def C64_Z : R600Reg <"C64.Z", 64>;
def C64_W : R600Reg <"C64.W", 64>;
def C65_X : R600Reg <"C65.X", 65>;
def C65_Y : R600Reg <"C65.Y", 65>;
def C65_Z : R600Reg <"C65.Z", 65>;
def C65_W : R600Reg <"C65.W", 65>;
def C66_X : R600Reg <"C66.X", 66>;
def C66_Y : R600Reg <"C66.Y", 66>;
def C66_Z : R600Reg <"C66.Z", 66>;
def C66_W : R600Reg <"C66.W", 66>;
def C67_X : R600Reg <"C67.X", 67>;
def C67_Y : R600Reg <"C67.Y", 67>;
def C67_Z : R600Reg <"C67.Z", 67>;
def C67_W : R600Reg <"C67.W", 67>;
def C68_X : R600Reg <"C68.X", 68>;
def C68_Y : R600Reg <"C68.Y", 68>;
def C68_Z : R600Reg <"C68.Z", 68>;
def C68_W : R600Reg <"C68.W", 68>;
def C69_X : R600Reg <"C69.X", 69>;
def C69_Y : R600Reg <"C69.Y", 69>;
def C69_Z : R600Reg <"C69.Z", 69>;
def C69_W : R600Reg <"C69.W", 69>;
def C70_X : R600Reg <"C70.X", 70>;
def C70_Y : R600Reg <"C70.Y", 70>;
def C70_Z : R600Reg <"C70.Z", 70>;
def C70_W : R600Reg <"C70.W", 70>;
def C71_X : R600Reg <"C71.X", 71>;
def C71_Y : R600Reg <"C71.Y", 71>;
def C71_Z : R600Reg <"C71.Z", 71>;
def C71_W : R600Reg <"C71.W", 71>;
def C72_X : R600Reg <"C72.X", 72>;
def C72_Y : R600Reg <"C72.Y", 72>;
def C72_Z : R600Reg <"C72.Z", 72>;
def C72_W : R600Reg <"C72.W", 72>;
def C73_X : R600Reg <"C73.X", 73>;
def C73_Y : R600Reg <"C73.Y", 73>;
def C73_Z : R600Reg <"C73.Z", 73>;
def C73_W : R600Reg <"C73.W", 73>;
def C74_X : R600Reg <"C74.X", 74>;
def C74_Y : R600Reg <"C74.Y", 74>;
def C74_Z : R600Reg <"C74.Z", 74>;
def C74_W : R600Reg <"C74.W", 74>;
def C75_X : R600Reg <"C75.X", 75>;
def C75_Y : R600Reg <"C75.Y", 75>;
def C75_Z : R600Reg <"C75.Z", 75>;
def C75_W : R600Reg <"C75.W", 75>;
def C76_X : R600Reg <"C76.X", 76>;
def C76_Y : R600Reg <"C76.Y", 76>;
def C76_Z : R600Reg <"C76.Z", 76>;
def C76_W : R600Reg <"C76.W", 76>;
def C77_X : R600Reg <"C77.X", 77>;
def C77_Y : R600Reg <"C77.Y", 77>;
def C77_Z : R600Reg <"C77.Z", 77>;
def C77_W : R600Reg <"C77.W", 77>;
def C78_X : R600Reg <"C78.X", 78>;
def C78_Y : R600Reg <"C78.Y", 78>;
def C78_Z : R600Reg <"C78.Z", 78>;
def C78_W : R600Reg <"C78.W", 78>;
def C79_X : R600Reg <"C79.X", 79>;
def C79_Y : R600Reg <"C79.Y", 79>;
def C79_Z : R600Reg <"C79.Z", 79>;
def C79_W : R600Reg <"C79.W", 79>;
def C80_X : R600Reg <"C80.X", 80>;
def C80_Y : R600Reg <"C80.Y", 80>;
def C80_Z : R600Reg <"C80.Z", 80>;
def C80_W : R600Reg <"C80.W", 80>;
def C81_X : R600Reg <"C81.X", 81>;
def C81_Y : R600Reg <"C81.Y", 81>;
def C81_Z : R600Reg <"C81.Z", 81>;
def C81_W : R600Reg <"C81.W", 81>;
def C82_X : R600Reg <"C82.X", 82>;
def C82_Y : R600Reg <"C82.Y", 82>;
def C82_Z : R600Reg <"C82.Z", 82>;
def C82_W : R600Reg <"C82.W", 82>;
def C83_X : R600Reg <"C83.X", 83>;
def C83_Y : R600Reg <"C83.Y", 83>;
def C83_Z : R600Reg <"C83.Z", 83>;
def C83_W : R600Reg <"C83.W", 83>;
def C84_X : R600Reg <"C84.X", 84>;
def C84_Y : R600Reg <"C84.Y", 84>;
def C84_Z : R600Reg <"C84.Z", 84>;
def C84_W : R600Reg <"C84.W", 84>;
def C85_X : R600Reg <"C85.X", 85>;
def C85_Y : R600Reg <"C85.Y", 85>;
def C85_Z : R600Reg <"C85.Z", 85>;
def C85_W : R600Reg <"C85.W", 85>;
def C86_X : R600Reg <"C86.X", 86>;
def C86_Y : R600Reg <"C86.Y", 86>;
def C86_Z : R600Reg <"C86.Z", 86>;
def C86_W : R600Reg <"C86.W", 86>;
def C87_X : R600Reg <"C87.X", 87>;
def C87_Y : R600Reg <"C87.Y", 87>;
def C87_Z : R600Reg <"C87.Z", 87>;
def C87_W : R600Reg <"C87.W", 87>;
def C88_X : R600Reg <"C88.X", 88>;
def C88_Y : R600Reg <"C88.Y", 88>;
def C88_Z : R600Reg <"C88.Z", 88>;
def C88_W : R600Reg <"C88.W", 88>;
def C89_X : R600Reg <"C89.X", 89>;
def C89_Y : R600Reg <"C89.Y", 89>;
def C89_Z : R600Reg <"C89.Z", 89>;
def C89_W : R600Reg <"C89.W", 89>;
def C90_X : R600Reg <"C90.X", 90>;
def C90_Y : R600Reg <"C90.Y", 90>;
def C90_Z : R600Reg <"C90.Z", 90>;
def C90_W : R600Reg <"C90.W", 90>;
def C91_X : R600Reg <"C91.X", 91>;
def C91_Y : R600Reg <"C91.Y", 91>;
def C91_Z : R600Reg <"C91.Z", 91>;
def C91_W : R600Reg <"C91.W", 91>;
def C92_X : R600Reg <"C92.X", 92>;
def C92_Y : R600Reg <"C92.Y", 92>;
def C92_Z : R600Reg <"C92.Z", 92>;
def C92_W : R600Reg <"C92.W", 92>;
def C93_X : R600Reg <"C93.X", 93>;
def C93_Y : R600Reg <"C93.Y", 93>;
def C93_Z : R600Reg <"C93.Z", 93>;
def C93_W : R600Reg <"C93.W", 93>;
def C94_X : R600Reg <"C94.X", 94>;
def C94_Y : R600Reg <"C94.Y", 94>;
def C94_Z : R600Reg <"C94.Z", 94>;
def C94_W : R600Reg <"C94.W", 94>;
def C95_X : R600Reg <"C95.X", 95>;
def C95_Y : R600Reg <"C95.Y", 95>;
def C95_Z : R600Reg <"C95.Z", 95>;
def C95_W : R600Reg <"C95.W", 95>;
def C96_X : R600Reg <"C96.X", 96>;
def C96_Y : R600Reg <"C96.Y", 96>;
def C96_Z : R600Reg <"C96.Z", 96>;
def C96_W : R600Reg <"C96.W", 96>;
def C97_X : R600Reg <"C97.X", 97>;
def C97_Y : R600Reg <"C97.Y", 97>;
def C97_Z : R600Reg <"C97.Z", 97>;
def C97_W : R600Reg <"C97.W", 97>;
def C98_X : R600Reg <"C98.X", 98>;
def C98_Y : R600Reg <"C98.Y", 98>;
def C98_Z : R600Reg <"C98.Z", 98>;
def C98_W : R600Reg <"C98.W", 98>;
def C99_X : R600Reg <"C99.X", 99>;
def C99_Y : R600Reg <"C99.Y", 99>;
def C99_Z : R600Reg <"C99.Z", 99>;
def C99_W : R600Reg <"C99.W", 99>;
def T0_X : R600Reg <"T0.X", 0>;
def T0_Y : R600Reg <"T0.Y", 0>;
def T0_Z : R600Reg <"T0.Z", 0>;
def T0_W : R600Reg <"T0.W", 0>;
def T1_X : R600Reg <"T1.X", 1>;
def T1_Y : R600Reg <"T1.Y", 1>;
def T1_Z : R600Reg <"T1.Z", 1>;
def T1_W : R600Reg <"T1.W", 1>;
def T2_X : R600Reg <"T2.X", 2>;
def T2_Y : R600Reg <"T2.Y", 2>;
def T2_Z : R600Reg <"T2.Z", 2>;
def T2_W : R600Reg <"T2.W", 2>;
def T3_X : R600Reg <"T3.X", 3>;
def T3_Y : R600Reg <"T3.Y", 3>;
def T3_Z : R600Reg <"T3.Z", 3>;
def T3_W : R600Reg <"T3.W", 3>;
def T4_X : R600Reg <"T4.X", 4>;
def T4_Y : R600Reg <"T4.Y", 4>;
def T4_Z : R600Reg <"T4.Z", 4>;
def T4_W : R600Reg <"T4.W", 4>;
def T5_X : R600Reg <"T5.X", 5>;
def T5_Y : R600Reg <"T5.Y", 5>;
def T5_Z : R600Reg <"T5.Z", 5>;
def T5_W : R600Reg <"T5.W", 5>;
def T6_X : R600Reg <"T6.X", 6>;
def T6_Y : R600Reg <"T6.Y", 6>;
def T6_Z : R600Reg <"T6.Z", 6>;
def T6_W : R600Reg <"T6.W", 6>;
def T7_X : R600Reg <"T7.X", 7>;
def T7_Y : R600Reg <"T7.Y", 7>;
def T7_Z : R600Reg <"T7.Z", 7>;
def T7_W : R600Reg <"T7.W", 7>;
def T8_X : R600Reg <"T8.X", 8>;
def T8_Y : R600Reg <"T8.Y", 8>;
def T8_Z : R600Reg <"T8.Z", 8>;
def T8_W : R600Reg <"T8.W", 8>;
def T9_X : R600Reg <"T9.X", 9>;
def T9_Y : R600Reg <"T9.Y", 9>;
def T9_Z : R600Reg <"T9.Z", 9>;
def T9_W : R600Reg <"T9.W", 9>;
def T10_X : R600Reg <"T10.X", 10>;
def T10_Y : R600Reg <"T10.Y", 10>;
def T10_Z : R600Reg <"T10.Z", 10>;
def T10_W : R600Reg <"T10.W", 10>;
def T11_X : R600Reg <"T11.X", 11>;
def T11_Y : R600Reg <"T11.Y", 11>;
def T11_Z : R600Reg <"T11.Z", 11>;
def T11_W : R600Reg <"T11.W", 11>;
def T12_X : R600Reg <"T12.X", 12>;
def T12_Y : R600Reg <"T12.Y", 12>;
def T12_Z : R600Reg <"T12.Z", 12>;
def T12_W : R600Reg <"T12.W", 12>;
def T13_X : R600Reg <"T13.X", 13>;
def T13_Y : R600Reg <"T13.Y", 13>;
def T13_Z : R600Reg <"T13.Z", 13>;
def T13_W : R600Reg <"T13.W", 13>;
def T14_X : R600Reg <"T14.X", 14>;
def T14_Y : R600Reg <"T14.Y", 14>;
def T14_Z : R600Reg <"T14.Z", 14>;
def T14_W : R600Reg <"T14.W", 14>;
def T15_X : R600Reg <"T15.X", 15>;
def T15_Y : R600Reg <"T15.Y", 15>;
def T15_Z : R600Reg <"T15.Z", 15>;
def T15_W : R600Reg <"T15.W", 15>;
def T16_X : R600Reg <"T16.X", 16>;
def T16_Y : R600Reg <"T16.Y", 16>;
def T16_Z : R600Reg <"T16.Z", 16>;
def T16_W : R600Reg <"T16.W", 16>;
def T17_X : R600Reg <"T17.X", 17>;
def T17_Y : R600Reg <"T17.Y", 17>;
def T17_Z : R600Reg <"T17.Z", 17>;
def T17_W : R600Reg <"T17.W", 17>;
def T18_X : R600Reg <"T18.X", 18>;
def T18_Y : R600Reg <"T18.Y", 18>;
def T18_Z : R600Reg <"T18.Z", 18>;
def T18_W : R600Reg <"T18.W", 18>;
def T19_X : R600Reg <"T19.X", 19>;
def T19_Y : R600Reg <"T19.Y", 19>;
def T19_Z : R600Reg <"T19.Z", 19>;
def T19_W : R600Reg <"T19.W", 19>;
def T20_X : R600Reg <"T20.X", 20>;
def T20_Y : R600Reg <"T20.Y", 20>;
def T20_Z : R600Reg <"T20.Z", 20>;
def T20_W : R600Reg <"T20.W", 20>;
def T21_X : R600Reg <"T21.X", 21>;
def T21_Y : R600Reg <"T21.Y", 21>;
def T21_Z : R600Reg <"T21.Z", 21>;
def T21_W : R600Reg <"T21.W", 21>;
def T22_X : R600Reg <"T22.X", 22>;
def T22_Y : R600Reg <"T22.Y", 22>;
def T22_Z : R600Reg <"T22.Z", 22>;
def T22_W : R600Reg <"T22.W", 22>;
def T23_X : R600Reg <"T23.X", 23>;
def T23_Y : R600Reg <"T23.Y", 23>;
def T23_Z : R600Reg <"T23.Z", 23>;
def T23_W : R600Reg <"T23.W", 23>;
def T24_X : R600Reg <"T24.X", 24>;
def T24_Y : R600Reg <"T24.Y", 24>;
def T24_Z : R600Reg <"T24.Z", 24>;
def T24_W : R600Reg <"T24.W", 24>;
def T25_X : R600Reg <"T25.X", 25>;
def T25_Y : R600Reg <"T25.Y", 25>;
def T25_Z : R600Reg <"T25.Z", 25>;
def T25_W : R600Reg <"T25.W", 25>;
def T26_X : R600Reg <"T26.X", 26>;
def T26_Y : R600Reg <"T26.Y", 26>;
def T26_Z : R600Reg <"T26.Z", 26>;
def T26_W : R600Reg <"T26.W", 26>;
def T27_X : R600Reg <"T27.X", 27>;
def T27_Y : R600Reg <"T27.Y", 27>;
def T27_Z : R600Reg <"T27.Z", 27>;
def T27_W : R600Reg <"T27.W", 27>;
def T28_X : R600Reg <"T28.X", 28>;
def T28_Y : R600Reg <"T28.Y", 28>;
def T28_Z : R600Reg <"T28.Z", 28>;
def T28_W : R600Reg <"T28.W", 28>;
def T29_X : R600Reg <"T29.X", 29>;
def T29_Y : R600Reg <"T29.Y", 29>;
def T29_Z : R600Reg <"T29.Z", 29>;
def T29_W : R600Reg <"T29.W", 29>;
def T30_X : R600Reg <"T30.X", 30>;
def T30_Y : R600Reg <"T30.Y", 30>;
def T30_Z : R600Reg <"T30.Z", 30>;
def T30_W : R600Reg <"T30.W", 30>;
def T31_X : R600Reg <"T31.X", 31>;
def T31_Y : R600Reg <"T31.Y", 31>;
def T31_Z : R600Reg <"T31.Z", 31>;
def T31_W : R600Reg <"T31.W", 31>;
def T32_X : R600Reg <"T32.X", 32>;
def T32_Y : R600Reg <"T32.Y", 32>;
def T32_Z : R600Reg <"T32.Z", 32>;
def T32_W : R600Reg <"T32.W", 32>;
def T33_X : R600Reg <"T33.X", 33>;
def T33_Y : R600Reg <"T33.Y", 33>;
def T33_Z : R600Reg <"T33.Z", 33>;
def T33_W : R600Reg <"T33.W", 33>;
def T34_X : R600Reg <"T34.X", 34>;
def T34_Y : R600Reg <"T34.Y", 34>;
def T34_Z : R600Reg <"T34.Z", 34>;
def T34_W : R600Reg <"T34.W", 34>;
def T35_X : R600Reg <"T35.X", 35>;
def T35_Y : R600Reg <"T35.Y", 35>;
def T35_Z : R600Reg <"T35.Z", 35>;
def T35_W : R600Reg <"T35.W", 35>;
def T36_X : R600Reg <"T36.X", 36>;
def T36_Y : R600Reg <"T36.Y", 36>;
def T36_Z : R600Reg <"T36.Z", 36>;
def T36_W : R600Reg <"T36.W", 36>;
def T37_X : R600Reg <"T37.X", 37>;
def T37_Y : R600Reg <"T37.Y", 37>;
def T37_Z : R600Reg <"T37.Z", 37>;
def T37_W : R600Reg <"T37.W", 37>;
def T38_X : R600Reg <"T38.X", 38>;
def T38_Y : R600Reg <"T38.Y", 38>;
def T38_Z : R600Reg <"T38.Z", 38>;
def T38_W : R600Reg <"T38.W", 38>;
def T39_X : R600Reg <"T39.X", 39>;
def T39_Y : R600Reg <"T39.Y", 39>;
def T39_Z : R600Reg <"T39.Z", 39>;
def T39_W : R600Reg <"T39.W", 39>;
def T40_X : R600Reg <"T40.X", 40>;
def T40_Y : R600Reg <"T40.Y", 40>;
def T40_Z : R600Reg <"T40.Z", 40>;
def T40_W : R600Reg <"T40.W", 40>;
def T41_X : R600Reg <"T41.X", 41>;
def T41_Y : R600Reg <"T41.Y", 41>;
def T41_Z : R600Reg <"T41.Z", 41>;
def T41_W : R600Reg <"T41.W", 41>;
def T42_X : R600Reg <"T42.X", 42>;
def T42_Y : R600Reg <"T42.Y", 42>;
def T42_Z : R600Reg <"T42.Z", 42>;
def T42_W : R600Reg <"T42.W", 42>;
def T43_X : R600Reg <"T43.X", 43>;
def T43_Y : R600Reg <"T43.Y", 43>;
def T43_Z : R600Reg <"T43.Z", 43>;
def T43_W : R600Reg <"T43.W", 43>;
def T44_X : R600Reg <"T44.X", 44>;
def T44_Y : R600Reg <"T44.Y", 44>;
def T44_Z : R600Reg <"T44.Z", 44>;
def T44_W : R600Reg <"T44.W", 44>;
def T45_X : R600Reg <"T45.X", 45>;
def T45_Y : R600Reg <"T45.Y", 45>;
def T45_Z : R600Reg <"T45.Z", 45>;
def T45_W : R600Reg <"T45.W", 45>;
def T46_X : R600Reg <"T46.X", 46>;
def T46_Y : R600Reg <"T46.Y", 46>;
def T46_Z : R600Reg <"T46.Z", 46>;
def T46_W : R600Reg <"T46.W", 46>;
def T47_X : R600Reg <"T47.X", 47>;
def T47_Y : R600Reg <"T47.Y", 47>;
def T47_Z : R600Reg <"T47.Z", 47>;
def T47_W : R600Reg <"T47.W", 47>;
def T48_X : R600Reg <"T48.X", 48>;
def T48_Y : R600Reg <"T48.Y", 48>;
def T48_Z : R600Reg <"T48.Z", 48>;
def T48_W : R600Reg <"T48.W", 48>;
def T49_X : R600Reg <"T49.X", 49>;
def T49_Y : R600Reg <"T49.Y", 49>;
def T49_Z : R600Reg <"T49.Z", 49>;
def T49_W : R600Reg <"T49.W", 49>;
def T50_X : R600Reg <"T50.X", 50>;
def T50_Y : R600Reg <"T50.Y", 50>;
def T50_Z : R600Reg <"T50.Z", 50>;
def T50_W : R600Reg <"T50.W", 50>;
def T51_X : R600Reg <"T51.X", 51>;
def T51_Y : R600Reg <"T51.Y", 51>;
def T51_Z : R600Reg <"T51.Z", 51>;
def T51_W : R600Reg <"T51.W", 51>;
def T52_X : R600Reg <"T52.X", 52>;
def T52_Y : R600Reg <"T52.Y", 52>;
def T52_Z : R600Reg <"T52.Z", 52>;
def T52_W : R600Reg <"T52.W", 52>;
def T53_X : R600Reg <"T53.X", 53>;
def T53_Y : R600Reg <"T53.Y", 53>;
def T53_Z : R600Reg <"T53.Z", 53>;
def T53_W : R600Reg <"T53.W", 53>;
def T54_X : R600Reg <"T54.X", 54>;
def T54_Y : R600Reg <"T54.Y", 54>;
def T54_Z : R600Reg <"T54.Z", 54>;
def T54_W : R600Reg <"T54.W", 54>;
def T55_X : R600Reg <"T55.X", 55>;
def T55_Y : R600Reg <"T55.Y", 55>;
def T55_Z : R600Reg <"T55.Z", 55>;
def T55_W : R600Reg <"T55.W", 55>;
def T56_X : R600Reg <"T56.X", 56>;
def T56_Y : R600Reg <"T56.Y", 56>;
def T56_Z : R600Reg <"T56.Z", 56>;
def T56_W : R600Reg <"T56.W", 56>;
def T57_X : R600Reg <"T57.X", 57>;
def T57_Y : R600Reg <"T57.Y", 57>;
def T57_Z : R600Reg <"T57.Z", 57>;
def T57_W : R600Reg <"T57.W", 57>;
def T58_X : R600Reg <"T58.X", 58>;
def T58_Y : R600Reg <"T58.Y", 58>;
def T58_Z : R600Reg <"T58.Z", 58>;
def T58_W : R600Reg <"T58.W", 58>;
def T59_X : R600Reg <"T59.X", 59>;
def T59_Y : R600Reg <"T59.Y", 59>;
def T59_Z : R600Reg <"T59.Z", 59>;
def T59_W : R600Reg <"T59.W", 59>;
def T60_X : R600Reg <"T60.X", 60>;
def T60_Y : R600Reg <"T60.Y", 60>;
def T60_Z : R600Reg <"T60.Z", 60>;
def T60_W : R600Reg <"T60.W", 60>;
def T61_X : R600Reg <"T61.X", 61>;
def T61_Y : R600Reg <"T61.Y", 61>;
def T61_Z : R600Reg <"T61.Z", 61>;
def T61_W : R600Reg <"T61.W", 61>;
def T62_X : R600Reg <"T62.X", 62>;
def T62_Y : R600Reg <"T62.Y", 62>;
def T62_Z : R600Reg <"T62.Z", 62>;
def T62_W : R600Reg <"T62.W", 62>;
def T63_X : R600Reg <"T63.X", 63>;
def T63_Y : R600Reg <"T63.Y", 63>;
def T63_Z : R600Reg <"T63.Z", 63>;
def T63_W : R600Reg <"T63.W", 63>;
def T64_X : R600Reg <"T64.X", 64>;
def T64_Y : R600Reg <"T64.Y", 64>;
def T64_Z : R600Reg <"T64.Z", 64>;
def T64_W : R600Reg <"T64.W", 64>;
def T65_X : R600Reg <"T65.X", 65>;
def T65_Y : R600Reg <"T65.Y", 65>;
def T65_Z : R600Reg <"T65.Z", 65>;
def T65_W : R600Reg <"T65.W", 65>;
def T66_X : R600Reg <"T66.X", 66>;
def T66_Y : R600Reg <"T66.Y", 66>;
def T66_Z : R600Reg <"T66.Z", 66>;
def T66_W : R600Reg <"T66.W", 66>;
def T67_X : R600Reg <"T67.X", 67>;
def T67_Y : R600Reg <"T67.Y", 67>;
def T67_Z : R600Reg <"T67.Z", 67>;
def T67_W : R600Reg <"T67.W", 67>;
def T68_X : R600Reg <"T68.X", 68>;
def T68_Y : R600Reg <"T68.Y", 68>;
def T68_Z : R600Reg <"T68.Z", 68>;
def T68_W : R600Reg <"T68.W", 68>;
def T69_X : R600Reg <"T69.X", 69>;
def T69_Y : R600Reg <"T69.Y", 69>;
def T69_Z : R600Reg <"T69.Z", 69>;
def T69_W : R600Reg <"T69.W", 69>;
def T70_X : R600Reg <"T70.X", 70>;
def T70_Y : R600Reg <"T70.Y", 70>;
def T70_Z : R600Reg <"T70.Z", 70>;
def T70_W : R600Reg <"T70.W", 70>;
def T71_X : R600Reg <"T71.X", 71>;
def T71_Y : R600Reg <"T71.Y", 71>;
def T71_Z : R600Reg <"T71.Z", 71>;
def T71_W : R600Reg <"T71.W", 71>;
def T72_X : R600Reg <"T72.X", 72>;
def T72_Y : R600Reg <"T72.Y", 72>;
def T72_Z : R600Reg <"T72.Z", 72>;
def T72_W : R600Reg <"T72.W", 72>;
def T73_X : R600Reg <"T73.X", 73>;
def T73_Y : R600Reg <"T73.Y", 73>;
def T73_Z : R600Reg <"T73.Z", 73>;
def T73_W : R600Reg <"T73.W", 73>;
def T74_X : R600Reg <"T74.X", 74>;
def T74_Y : R600Reg <"T74.Y", 74>;
def T74_Z : R600Reg <"T74.Z", 74>;
def T74_W : R600Reg <"T74.W", 74>;
def T75_X : R600Reg <"T75.X", 75>;
def T75_Y : R600Reg <"T75.Y", 75>;
def T75_Z : R600Reg <"T75.Z", 75>;
def T75_W : R600Reg <"T75.W", 75>;
def T76_X : R600Reg <"T76.X", 76>;
def T76_Y : R600Reg <"T76.Y", 76>;
def T76_Z : R600Reg <"T76.Z", 76>;
def T76_W : R600Reg <"T76.W", 76>;
def T77_X : R600Reg <"T77.X", 77>;
def T77_Y : R600Reg <"T77.Y", 77>;
def T77_Z : R600Reg <"T77.Z", 77>;
def T77_W : R600Reg <"T77.W", 77>;
def T78_X : R600Reg <"T78.X", 78>;
def T78_Y : R600Reg <"T78.Y", 78>;
def T78_Z : R600Reg <"T78.Z", 78>;
def T78_W : R600Reg <"T78.W", 78>;
def T79_X : R600Reg <"T79.X", 79>;
def T79_Y : R600Reg <"T79.Y", 79>;
def T79_Z : R600Reg <"T79.Z", 79>;
def T79_W : R600Reg <"T79.W", 79>;
def T80_X : R600Reg <"T80.X", 80>;
def T80_Y : R600Reg <"T80.Y", 80>;
def T80_Z : R600Reg <"T80.Z", 80>;
def T80_W : R600Reg <"T80.W", 80>;
def T81_X : R600Reg <"T81.X", 81>;
def T81_Y : R600Reg <"T81.Y", 81>;
def T81_Z : R600Reg <"T81.Z", 81>;
def T81_W : R600Reg <"T81.W", 81>;
def T82_X : R600Reg <"T82.X", 82>;
def T82_Y : R600Reg <"T82.Y", 82>;
def T82_Z : R600Reg <"T82.Z", 82>;
def T82_W : R600Reg <"T82.W", 82>;
def T83_X : R600Reg <"T83.X", 83>;
def T83_Y : R600Reg <"T83.Y", 83>;
def T83_Z : R600Reg <"T83.Z", 83>;
def T83_W : R600Reg <"T83.W", 83>;
def T84_X : R600Reg <"T84.X", 84>;
def T84_Y : R600Reg <"T84.Y", 84>;
def T84_Z : R600Reg <"T84.Z", 84>;
def T84_W : R600Reg <"T84.W", 84>;
def T85_X : R600Reg <"T85.X", 85>;
def T85_Y : R600Reg <"T85.Y", 85>;
def T85_Z : R600Reg <"T85.Z", 85>;
def T85_W : R600Reg <"T85.W", 85>;
def T86_X : R600Reg <"T86.X", 86>;
def T86_Y : R600Reg <"T86.Y", 86>;
def T86_Z : R600Reg <"T86.Z", 86>;
def T86_W : R600Reg <"T86.W", 86>;
def T87_X : R600Reg <"T87.X", 87>;
def T87_Y : R600Reg <"T87.Y", 87>;
def T87_Z : R600Reg <"T87.Z", 87>;
def T87_W : R600Reg <"T87.W", 87>;
def T88_X : R600Reg <"T88.X", 88>;
def T88_Y : R600Reg <"T88.Y", 88>;
def T88_Z : R600Reg <"T88.Z", 88>;
def T88_W : R600Reg <"T88.W", 88>;
def T89_X : R600Reg <"T89.X", 89>;
def T89_Y : R600Reg <"T89.Y", 89>;
def T89_Z : R600Reg <"T89.Z", 89>;
def T89_W : R600Reg <"T89.W", 89>;
def T90_X : R600Reg <"T90.X", 90>;
def T90_Y : R600Reg <"T90.Y", 90>;
def T90_Z : R600Reg <"T90.Z", 90>;
def T90_W : R600Reg <"T90.W", 90>;
def T91_X : R600Reg <"T91.X", 91>;
def T91_Y : R600Reg <"T91.Y", 91>;
def T91_Z : R600Reg <"T91.Z", 91>;
def T91_W : R600Reg <"T91.W", 91>;
def T92_X : R600Reg <"T92.X", 92>;
def T92_Y : R600Reg <"T92.Y", 92>;
def T92_Z : R600Reg <"T92.Z", 92>;
def T92_W : R600Reg <"T92.W", 92>;
def T93_X : R600Reg <"T93.X", 93>;
def T93_Y : R600Reg <"T93.Y", 93>;
def T93_Z : R600Reg <"T93.Z", 93>;
def T93_W : R600Reg <"T93.W", 93>;
def T94_X : R600Reg <"T94.X", 94>;
def T94_Y : R600Reg <"T94.Y", 94>;
def T94_Z : R600Reg <"T94.Z", 94>;
def T94_W : R600Reg <"T94.W", 94>;
def T95_X : R600Reg <"T95.X", 95>;
def T95_Y : R600Reg <"T95.Y", 95>;
def T95_Z : R600Reg <"T95.Z", 95>;
def T95_W : R600Reg <"T95.W", 95>;
def T96_X : R600Reg <"T96.X", 96>;
def T96_Y : R600Reg <"T96.Y", 96>;
def T96_Z : R600Reg <"T96.Z", 96>;
def T96_W : R600Reg <"T96.W", 96>;
def T97_X : R600Reg <"T97.X", 97>;
def T97_Y : R600Reg <"T97.Y", 97>;
def T97_Z : R600Reg <"T97.Z", 97>;
def T97_W : R600Reg <"T97.W", 97>;
def T98_X : R600Reg <"T98.X", 98>;
def T98_Y : R600Reg <"T98.Y", 98>;
def T98_Z : R600Reg <"T98.Z", 98>;
def T98_W : R600Reg <"T98.W", 98>;
def T99_X : R600Reg <"T99.X", 99>;
def T99_Y : R600Reg <"T99.Y", 99>;
def T99_Z : R600Reg <"T99.Z", 99>;
def T99_W : R600Reg <"T99.W", 99>;
def T100_X : R600Reg <"T100.X", 100>;
def T100_Y : R600Reg <"T100.Y", 100>;
def T100_Z : R600Reg <"T100.Z", 100>;
def T100_W : R600Reg <"T100.W", 100>;
def T101_X : R600Reg <"T101.X", 101>;
def T101_Y : R600Reg <"T101.Y", 101>;
def T101_Z : R600Reg <"T101.Z", 101>;
def T101_W : R600Reg <"T101.W", 101>;
def T102_X : R600Reg <"T102.X", 102>;
def T102_Y : R600Reg <"T102.Y", 102>;
def T102_Z : R600Reg <"T102.Z", 102>;
def T102_W : R600Reg <"T102.W", 102>;
def T103_X : R600Reg <"T103.X", 103>;
def T103_Y : R600Reg <"T103.Y", 103>;
def T103_Z : R600Reg <"T103.Z", 103>;
def T103_W : R600Reg <"T103.W", 103>;
def T104_X : R600Reg <"T104.X", 104>;
def T104_Y : R600Reg <"T104.Y", 104>;
def T104_Z : R600Reg <"T104.Z", 104>;
def T104_W : R600Reg <"T104.W", 104>;
def T105_X : R600Reg <"T105.X", 105>;
def T105_Y : R600Reg <"T105.Y", 105>;
def T105_Z : R600Reg <"T105.Z", 105>;
def T105_W : R600Reg <"T105.W", 105>;
def T106_X : R600Reg <"T106.X", 106>;
def T106_Y : R600Reg <"T106.Y", 106>;
def T106_Z : R600Reg <"T106.Z", 106>;
def T106_W : R600Reg <"T106.W", 106>;
def T107_X : R600Reg <"T107.X", 107>;
def T107_Y : R600Reg <"T107.Y", 107>;
def T107_Z : R600Reg <"T107.Z", 107>;
def T107_W : R600Reg <"T107.W", 107>;
def T108_X : R600Reg <"T108.X", 108>;
def T108_Y : R600Reg <"T108.Y", 108>;
def T108_Z : R600Reg <"T108.Z", 108>;
def T108_W : R600Reg <"T108.W", 108>;
def T109_X : R600Reg <"T109.X", 109>;
def T109_Y : R600Reg <"T109.Y", 109>;
def T109_Z : R600Reg <"T109.Z", 109>;
def T109_W : R600Reg <"T109.W", 109>;
def T110_X : R600Reg <"T110.X", 110>;
def T110_Y : R600Reg <"T110.Y", 110>;
def T110_Z : R600Reg <"T110.Z", 110>;
def T110_W : R600Reg <"T110.W", 110>;
def T111_X : R600Reg <"T111.X", 111>;
def T111_Y : R600Reg <"T111.Y", 111>;
def T111_Z : R600Reg <"T111.Z", 111>;
def T111_W : R600Reg <"T111.W", 111>;
def T112_X : R600Reg <"T112.X", 112>;
def T112_Y : R600Reg <"T112.Y", 112>;
def T112_Z : R600Reg <"T112.Z", 112>;
def T112_W : R600Reg <"T112.W", 112>;
def T113_X : R600Reg <"T113.X", 113>;
def T113_Y : R600Reg <"T113.Y", 113>;
def T113_Z : R600Reg <"T113.Z", 113>;
def T113_W : R600Reg <"T113.W", 113>;
def T114_X : R600Reg <"T114.X", 114>;
def T114_Y : R600Reg <"T114.Y", 114>;
def T114_Z : R600Reg <"T114.Z", 114>;
def T114_W : R600Reg <"T114.W", 114>;
def T115_X : R600Reg <"T115.X", 115>;
def T115_Y : R600Reg <"T115.Y", 115>;
def T115_Z : R600Reg <"T115.Z", 115>;
def T115_W : R600Reg <"T115.W", 115>;
def T116_X : R600Reg <"T116.X", 116>;
def T116_Y : R600Reg <"T116.Y", 116>;
def T116_Z : R600Reg <"T116.Z", 116>;
def T116_W : R600Reg <"T116.W", 116>;
def T117_X : R600Reg <"T117.X", 117>;
def T117_Y : R600Reg <"T117.Y", 117>;
def T117_Z : R600Reg <"T117.Z", 117>;
def T117_W : R600Reg <"T117.W", 117>;
def T118_X : R600Reg <"T118.X", 118>;
def T118_Y : R600Reg <"T118.Y", 118>;
def T118_Z : R600Reg <"T118.Z", 118>;
def T118_W : R600Reg <"T118.W", 118>;
def T119_X : R600Reg <"T119.X", 119>;
def T119_Y : R600Reg <"T119.Y", 119>;
def T119_Z : R600Reg <"T119.Z", 119>;
def T119_W : R600Reg <"T119.W", 119>;
def T120_X : R600Reg <"T120.X", 120>;
def T120_Y : R600Reg <"T120.Y", 120>;
def T120_Z : R600Reg <"T120.Z", 120>;
def T120_W : R600Reg <"T120.W", 120>;
def T121_X : R600Reg <"T121.X", 121>;
def T121_Y : R600Reg <"T121.Y", 121>;
def T121_Z : R600Reg <"T121.Z", 121>;
def T121_W : R600Reg <"T121.W", 121>;
def T122_X : R600Reg <"T122.X", 122>;
def T122_Y : R600Reg <"T122.Y", 122>;
def T122_Z : R600Reg <"T122.Z", 122>;
def T122_W : R600Reg <"T122.W", 122>;
def T123_X : R600Reg <"T123.X", 123>;
def T123_Y : R600Reg <"T123.Y", 123>;
def T123_Z : R600Reg <"T123.Z", 123>;
def T123_W : R600Reg <"T123.W", 123>;
def T124_X : R600Reg <"T124.X", 124>;
def T124_Y : R600Reg <"T124.Y", 124>;
def T124_Z : R600Reg <"T124.Z", 124>;
def T124_W : R600Reg <"T124.W", 124>;
def T125_X : R600Reg <"T125.X", 125>;
def T125_Y : R600Reg <"T125.Y", 125>;
def T125_Z : R600Reg <"T125.Z", 125>;
def T125_W : R600Reg <"T125.W", 125>;
def T126_X : R600Reg <"T126.X", 126>;
def T126_Y : R600Reg <"T126.Y", 126>;
def T126_Z : R600Reg <"T126.Z", 126>;
def T126_W : R600Reg <"T126.W", 126>;
def T127_X : R600Reg <"T127.X", 127>;
def T127_Y : R600Reg <"T127.Y", 127>;
def T127_Z : R600Reg <"T127.Z", 127>;
def T127_W : R600Reg <"T127.W", 127>;
def T0_XYZW : R600Reg_128 <"T0.XYZW", [T0_X, T0_Y, T0_Z, T0_W], 0 >;
def T1_XYZW : R600Reg_128 <"T1.XYZW", [T1_X, T1_Y, T1_Z, T1_W], 1 >;
def T2_XYZW : R600Reg_128 <"T2.XYZW", [T2_X, T2_Y, T2_Z, T2_W], 2 >;
def T3_XYZW : R600Reg_128 <"T3.XYZW", [T3_X, T3_Y, T3_Z, T3_W], 3 >;
def T4_XYZW : R600Reg_128 <"T4.XYZW", [T4_X, T4_Y, T4_Z, T4_W], 4 >;
def T5_XYZW : R600Reg_128 <"T5.XYZW", [T5_X, T5_Y, T5_Z, T5_W], 5 >;
def T6_XYZW : R600Reg_128 <"T6.XYZW", [T6_X, T6_Y, T6_Z, T6_W], 6 >;
def T7_XYZW : R600Reg_128 <"T7.XYZW", [T7_X, T7_Y, T7_Z, T7_W], 7 >;
def T8_XYZW : R600Reg_128 <"T8.XYZW", [T8_X, T8_Y, T8_Z, T8_W], 8 >;
def T9_XYZW : R600Reg_128 <"T9.XYZW", [T9_X, T9_Y, T9_Z, T9_W], 9 >;
def T10_XYZW : R600Reg_128 <"T10.XYZW", [T10_X, T10_Y, T10_Z, T10_W], 10 >;
def T11_XYZW : R600Reg_128 <"T11.XYZW", [T11_X, T11_Y, T11_Z, T11_W], 11 >;
def T12_XYZW : R600Reg_128 <"T12.XYZW", [T12_X, T12_Y, T12_Z, T12_W], 12 >;
def T13_XYZW : R600Reg_128 <"T13.XYZW", [T13_X, T13_Y, T13_Z, T13_W], 13 >;
def T14_XYZW : R600Reg_128 <"T14.XYZW", [T14_X, T14_Y, T14_Z, T14_W], 14 >;
def T15_XYZW : R600Reg_128 <"T15.XYZW", [T15_X, T15_Y, T15_Z, T15_W], 15 >;
def T16_XYZW : R600Reg_128 <"T16.XYZW", [T16_X, T16_Y, T16_Z, T16_W], 16 >;
def T17_XYZW : R600Reg_128 <"T17.XYZW", [T17_X, T17_Y, T17_Z, T17_W], 17 >;
def T18_XYZW : R600Reg_128 <"T18.XYZW", [T18_X, T18_Y, T18_Z, T18_W], 18 >;
def T19_XYZW : R600Reg_128 <"T19.XYZW", [T19_X, T19_Y, T19_Z, T19_W], 19 >;
def T20_XYZW : R600Reg_128 <"T20.XYZW", [T20_X, T20_Y, T20_Z, T20_W], 20 >;
def T21_XYZW : R600Reg_128 <"T21.XYZW", [T21_X, T21_Y, T21_Z, T21_W], 21 >;
def T22_XYZW : R600Reg_128 <"T22.XYZW", [T22_X, T22_Y, T22_Z, T22_W], 22 >;
def T23_XYZW : R600Reg_128 <"T23.XYZW", [T23_X, T23_Y, T23_Z, T23_W], 23 >;
def T24_XYZW : R600Reg_128 <"T24.XYZW", [T24_X, T24_Y, T24_Z, T24_W], 24 >;
def T25_XYZW : R600Reg_128 <"T25.XYZW", [T25_X, T25_Y, T25_Z, T25_W], 25 >;
def T26_XYZW : R600Reg_128 <"T26.XYZW", [T26_X, T26_Y, T26_Z, T26_W], 26 >;
def T27_XYZW : R600Reg_128 <"T27.XYZW", [T27_X, T27_Y, T27_Z, T27_W], 27 >;
def T28_XYZW : R600Reg_128 <"T28.XYZW", [T28_X, T28_Y, T28_Z, T28_W], 28 >;
def T29_XYZW : R600Reg_128 <"T29.XYZW", [T29_X, T29_Y, T29_Z, T29_W], 29 >;
def T30_XYZW : R600Reg_128 <"T30.XYZW", [T30_X, T30_Y, T30_Z, T30_W], 30 >;
def T31_XYZW : R600Reg_128 <"T31.XYZW", [T31_X, T31_Y, T31_Z, T31_W], 31 >;
def T32_XYZW : R600Reg_128 <"T32.XYZW", [T32_X, T32_Y, T32_Z, T32_W], 32 >;
def T33_XYZW : R600Reg_128 <"T33.XYZW", [T33_X, T33_Y, T33_Z, T33_W], 33 >;
def T34_XYZW : R600Reg_128 <"T34.XYZW", [T34_X, T34_Y, T34_Z, T34_W], 34 >;
def T35_XYZW : R600Reg_128 <"T35.XYZW", [T35_X, T35_Y, T35_Z, T35_W], 35 >;
def T36_XYZW : R600Reg_128 <"T36.XYZW", [T36_X, T36_Y, T36_Z, T36_W], 36 >;
def T37_XYZW : R600Reg_128 <"T37.XYZW", [T37_X, T37_Y, T37_Z, T37_W], 37 >;
def T38_XYZW : R600Reg_128 <"T38.XYZW", [T38_X, T38_Y, T38_Z, T38_W], 38 >;
def T39_XYZW : R600Reg_128 <"T39.XYZW", [T39_X, T39_Y, T39_Z, T39_W], 39 >;
def T40_XYZW : R600Reg_128 <"T40.XYZW", [T40_X, T40_Y, T40_Z, T40_W], 40 >;
def T41_XYZW : R600Reg_128 <"T41.XYZW", [T41_X, T41_Y, T41_Z, T41_W], 41 >;
def T42_XYZW : R600Reg_128 <"T42.XYZW", [T42_X, T42_Y, T42_Z, T42_W], 42 >;
def T43_XYZW : R600Reg_128 <"T43.XYZW", [T43_X, T43_Y, T43_Z, T43_W], 43 >;
def T44_XYZW : R600Reg_128 <"T44.XYZW", [T44_X, T44_Y, T44_Z, T44_W], 44 >;
def T45_XYZW : R600Reg_128 <"T45.XYZW", [T45_X, T45_Y, T45_Z, T45_W], 45 >;
def T46_XYZW : R600Reg_128 <"T46.XYZW", [T46_X, T46_Y, T46_Z, T46_W], 46 >;
def T47_XYZW : R600Reg_128 <"T47.XYZW", [T47_X, T47_Y, T47_Z, T47_W], 47 >;
def T48_XYZW : R600Reg_128 <"T48.XYZW", [T48_X, T48_Y, T48_Z, T48_W], 48 >;
def T49_XYZW : R600Reg_128 <"T49.XYZW", [T49_X, T49_Y, T49_Z, T49_W], 49 >;
def T50_XYZW : R600Reg_128 <"T50.XYZW", [T50_X, T50_Y, T50_Z, T50_W], 50 >;
def T51_XYZW : R600Reg_128 <"T51.XYZW", [T51_X, T51_Y, T51_Z, T51_W], 51 >;
def T52_XYZW : R600Reg_128 <"T52.XYZW", [T52_X, T52_Y, T52_Z, T52_W], 52 >;
def T53_XYZW : R600Reg_128 <"T53.XYZW", [T53_X, T53_Y, T53_Z, T53_W], 53 >;
def T54_XYZW : R600Reg_128 <"T54.XYZW", [T54_X, T54_Y, T54_Z, T54_W], 54 >;
def T55_XYZW : R600Reg_128 <"T55.XYZW", [T55_X, T55_Y, T55_Z, T55_W], 55 >;
def T56_XYZW : R600Reg_128 <"T56.XYZW", [T56_X, T56_Y, T56_Z, T56_W], 56 >;
def T57_XYZW : R600Reg_128 <"T57.XYZW", [T57_X, T57_Y, T57_Z, T57_W], 57 >;
def T58_XYZW : R600Reg_128 <"T58.XYZW", [T58_X, T58_Y, T58_Z, T58_W], 58 >;
def T59_XYZW : R600Reg_128 <"T59.XYZW", [T59_X, T59_Y, T59_Z, T59_W], 59 >;
def T60_XYZW : R600Reg_128 <"T60.XYZW", [T60_X, T60_Y, T60_Z, T60_W], 60 >;
def T61_XYZW : R600Reg_128 <"T61.XYZW", [T61_X, T61_Y, T61_Z, T61_W], 61 >;
def T62_XYZW : R600Reg_128 <"T62.XYZW", [T62_X, T62_Y, T62_Z, T62_W], 62 >;
def T63_XYZW : R600Reg_128 <"T63.XYZW", [T63_X, T63_Y, T63_Z, T63_W], 63 >;
def T64_XYZW : R600Reg_128 <"T64.XYZW", [T64_X, T64_Y, T64_Z, T64_W], 64 >;
def T65_XYZW : R600Reg_128 <"T65.XYZW", [T65_X, T65_Y, T65_Z, T65_W], 65 >;
def T66_XYZW : R600Reg_128 <"T66.XYZW", [T66_X, T66_Y, T66_Z, T66_W], 66 >;
def T67_XYZW : R600Reg_128 <"T67.XYZW", [T67_X, T67_Y, T67_Z, T67_W], 67 >;
def T68_XYZW : R600Reg_128 <"T68.XYZW", [T68_X, T68_Y, T68_Z, T68_W], 68 >;
def T69_XYZW : R600Reg_128 <"T69.XYZW", [T69_X, T69_Y, T69_Z, T69_W], 69 >;
def T70_XYZW : R600Reg_128 <"T70.XYZW", [T70_X, T70_Y, T70_Z, T70_W], 70 >;
def T71_XYZW : R600Reg_128 <"T71.XYZW", [T71_X, T71_Y, T71_Z, T71_W], 71 >;
def T72_XYZW : R600Reg_128 <"T72.XYZW", [T72_X, T72_Y, T72_Z, T72_W], 72 >;
def T73_XYZW : R600Reg_128 <"T73.XYZW", [T73_X, T73_Y, T73_Z, T73_W], 73 >;
def T74_XYZW : R600Reg_128 <"T74.XYZW", [T74_X, T74_Y, T74_Z, T74_W], 74 >;
def T75_XYZW : R600Reg_128 <"T75.XYZW", [T75_X, T75_Y, T75_Z, T75_W], 75 >;
def T76_XYZW : R600Reg_128 <"T76.XYZW", [T76_X, T76_Y, T76_Z, T76_W], 76 >;
def T77_XYZW : R600Reg_128 <"T77.XYZW", [T77_X, T77_Y, T77_Z, T77_W], 77 >;
def T78_XYZW : R600Reg_128 <"T78.XYZW", [T78_X, T78_Y, T78_Z, T78_W], 78 >;
def T79_XYZW : R600Reg_128 <"T79.XYZW", [T79_X, T79_Y, T79_Z, T79_W], 79 >;
def T80_XYZW : R600Reg_128 <"T80.XYZW", [T80_X, T80_Y, T80_Z, T80_W], 80 >;
def T81_XYZW : R600Reg_128 <"T81.XYZW", [T81_X, T81_Y, T81_Z, T81_W], 81 >;
def T82_XYZW : R600Reg_128 <"T82.XYZW", [T82_X, T82_Y, T82_Z, T82_W], 82 >;
def T83_XYZW : R600Reg_128 <"T83.XYZW", [T83_X, T83_Y, T83_Z, T83_W], 83 >;
def T84_XYZW : R600Reg_128 <"T84.XYZW", [T84_X, T84_Y, T84_Z, T84_W], 84 >;
def T85_XYZW : R600Reg_128 <"T85.XYZW", [T85_X, T85_Y, T85_Z, T85_W], 85 >;
def T86_XYZW : R600Reg_128 <"T86.XYZW", [T86_X, T86_Y, T86_Z, T86_W], 86 >;
def T87_XYZW : R600Reg_128 <"T87.XYZW", [T87_X, T87_Y, T87_Z, T87_W], 87 >;
def T88_XYZW : R600Reg_128 <"T88.XYZW", [T88_X, T88_Y, T88_Z, T88_W], 88 >;
def T89_XYZW : R600Reg_128 <"T89.XYZW", [T89_X, T89_Y, T89_Z, T89_W], 89 >;
def T90_XYZW : R600Reg_128 <"T90.XYZW", [T90_X, T90_Y, T90_Z, T90_W], 90 >;
def T91_XYZW : R600Reg_128 <"T91.XYZW", [T91_X, T91_Y, T91_Z, T91_W], 91 >;
def T92_XYZW : R600Reg_128 <"T92.XYZW", [T92_X, T92_Y, T92_Z, T92_W], 92 >;
def T93_XYZW : R600Reg_128 <"T93.XYZW", [T93_X, T93_Y, T93_Z, T93_W], 93 >;
def T94_XYZW : R600Reg_128 <"T94.XYZW", [T94_X, T94_Y, T94_Z, T94_W], 94 >;
def T95_XYZW : R600Reg_128 <"T95.XYZW", [T95_X, T95_Y, T95_Z, T95_W], 95 >;
def T96_XYZW : R600Reg_128 <"T96.XYZW", [T96_X, T96_Y, T96_Z, T96_W], 96 >;
def T97_XYZW : R600Reg_128 <"T97.XYZW", [T97_X, T97_Y, T97_Z, T97_W], 97 >;
def T98_XYZW : R600Reg_128 <"T98.XYZW", [T98_X, T98_Y, T98_Z, T98_W], 98 >;
def T99_XYZW : R600Reg_128 <"T99.XYZW", [T99_X, T99_Y, T99_Z, T99_W], 99 >;
def T100_XYZW : R600Reg_128 <"T100.XYZW", [T100_X, T100_Y, T100_Z, T100_W], 100 >;
def T101_XYZW : R600Reg_128 <"T101.XYZW", [T101_X, T101_Y, T101_Z, T101_W], 101 >;
def T102_XYZW : R600Reg_128 <"T102.XYZW", [T102_X, T102_Y, T102_Z, T102_W], 102 >;
def T103_XYZW : R600Reg_128 <"T103.XYZW", [T103_X, T103_Y, T103_Z, T103_W], 103 >;
def T104_XYZW : R600Reg_128 <"T104.XYZW", [T104_X, T104_Y, T104_Z, T104_W], 104 >;
def T105_XYZW : R600Reg_128 <"T105.XYZW", [T105_X, T105_Y, T105_Z, T105_W], 105 >;
def T106_XYZW : R600Reg_128 <"T106.XYZW", [T106_X, T106_Y, T106_Z, T106_W], 106 >;
def T107_XYZW : R600Reg_128 <"T107.XYZW", [T107_X, T107_Y, T107_Z, T107_W], 107 >;
def T108_XYZW : R600Reg_128 <"T108.XYZW", [T108_X, T108_Y, T108_Z, T108_W], 108 >;
def T109_XYZW : R600Reg_128 <"T109.XYZW", [T109_X, T109_Y, T109_Z, T109_W], 109 >;
def T110_XYZW : R600Reg_128 <"T110.XYZW", [T110_X, T110_Y, T110_Z, T110_W], 110 >;
def T111_XYZW : R600Reg_128 <"T111.XYZW", [T111_X, T111_Y, T111_Z, T111_W], 111 >;
def T112_XYZW : R600Reg_128 <"T112.XYZW", [T112_X, T112_Y, T112_Z, T112_W], 112 >;
def T113_XYZW : R600Reg_128 <"T113.XYZW", [T113_X, T113_Y, T113_Z, T113_W], 113 >;
def T114_XYZW : R600Reg_128 <"T114.XYZW", [T114_X, T114_Y, T114_Z, T114_W], 114 >;
def T115_XYZW : R600Reg_128 <"T115.XYZW", [T115_X, T115_Y, T115_Z, T115_W], 115 >;
def T116_XYZW : R600Reg_128 <"T116.XYZW", [T116_X, T116_Y, T116_Z, T116_W], 116 >;
def T117_XYZW : R600Reg_128 <"T117.XYZW", [T117_X, T117_Y, T117_Z, T117_W], 117 >;
def T118_XYZW : R600Reg_128 <"T118.XYZW", [T118_X, T118_Y, T118_Z, T118_W], 118 >;
def T119_XYZW : R600Reg_128 <"T119.XYZW", [T119_X, T119_Y, T119_Z, T119_W], 119 >;
def T120_XYZW : R600Reg_128 <"T120.XYZW", [T120_X, T120_Y, T120_Z, T120_W], 120 >;
def T121_XYZW : R600Reg_128 <"T121.XYZW", [T121_X, T121_Y, T121_Z, T121_W], 121 >;
def T122_XYZW : R600Reg_128 <"T122.XYZW", [T122_X, T122_Y, T122_Z, T122_W], 122 >;
def T123_XYZW : R600Reg_128 <"T123.XYZW", [T123_X, T123_Y, T123_Z, T123_W], 123 >;
def T124_XYZW : R600Reg_128 <"T124.XYZW", [T124_X, T124_Y, T124_Z, T124_W], 124 >;
def T125_XYZW : R600Reg_128 <"T125.XYZW", [T125_X, T125_Y, T125_Z, T125_W], 125 >;
def T126_XYZW : R600Reg_128 <"T126.XYZW", [T126_X, T126_Y, T126_Z, T126_W], 126 >;
def T127_XYZW : R600Reg_128 <"T127.XYZW", [T127_X, T127_Y, T127_Z, T127_W], 127 >;

class RegSet <dag s> {
  dag set = s;
}

def ZERO : R600Reg<"0.0", 248>;
def ONE : R600Reg<"1.0", 249>;
def NEG_ONE : R600Reg<"-1.0", 249>;
def ONE_INT : R600Reg<"1", 250>;
def HALF : R600Reg<"0.5", 252>;
def NEG_HALF : R600Reg<"-0.5", 252>;
def ALU_LITERAL_X : R600Reg<"literal.x", 253>;
def PV_X : R600Reg<"pv.x", 254>;
def PREDICATE_BIT : R600Reg<"PredicateBit", 0>;
def PRED_SEL_OFF: R600Reg<"Pred_sel_off", 0>;
def PRED_SEL_ZERO : R600Reg<"Pred_sel_zero", 0>;
def PRED_SEL_ONE : R600Reg<"Pred_sel_one", 0>;

def R600_CReg32 : RegisterClass <"AMDGPU", [f32, i32], 32, (add
    C0_X
,C0_Y,C0_Z,C0_W,C1_X,C1_Y,C1_Z,C1_W,C2_X,C2_Y,C2_Z
,C2_W,C3_X,C3_Y,C3_Z,C3_W,C4_X,C4_Y,C4_Z,C4_W,C5_X
,C5_Y,C5_Z,C5_W,C6_X,C6_Y,C6_Z,C6_W,C7_X,C7_Y,C7_Z
,C7_W,C8_X,C8_Y,C8_Z,C8_W,C9_X,C9_Y,C9_Z,C9_W,C10_X
,C10_Y,C10_Z,C10_W,C11_X,C11_Y,C11_Z,C11_W,C12_X,C12_Y,C12_Z
,C12_W,C13_X,C13_Y,C13_Z,C13_W,C14_X,C14_Y,C14_Z,C14_W,C15_X
,C15_Y,C15_Z,C15_W,C16_X,C16_Y,C16_Z,C16_W,C17_X,C17_Y,C17_Z
,C17_W,C18_X,C18_Y,C18_Z,C18_W,C19_X,C19_Y,C19_Z,C19_W,C20_X
,C20_Y,C20_Z,C20_W,C21_X,C21_Y,C21_Z,C21_W,C22_X,C22_Y,C22_Z
,C22_W,C23_X,C23_Y,C23_Z,C23_W,C24_X,C24_Y,C24_Z,C24_W,C25_X
,C25_Y,C25_Z,C25_W,C26_X,C26_Y,C26_Z,C26_W,C27_X,C27_Y,C27_Z
,C27_W,C28_X,C28_Y,C28_Z,C28_W,C29_X,C29_Y,C29_Z,C29_W,C30_X
,C30_Y,C30_Z,C30_W,C31_X,C31_Y,C31_Z,C31_W,C32_X,C32_Y,C32_Z
,C32_W,C33_X,C33_Y,C33_Z,C33_W,C34_X,C34_Y,C34_Z,C34_W,C35_X
,C35_Y,C35_Z,C35_W,C36_X,C36_Y,C36_Z,C36_W,C37_X,C37_Y,C37_Z
,C37_W,C38_X,C38_Y,C38_Z,C38_W,C39_X,C39_Y,C39_Z,C39_W,C40_X
,C40_Y,C40_Z,C40_W,C41_X,C41_Y,C41_Z,C41_W,C42_X,C42_Y,C42_Z
,C42_W,C43_X,C43_Y,C43_Z,C43_W,C44_X,C44_Y,C44_Z,C44_W,C45_X
,C45_Y,C45_Z,C45_W,C46_X,C46_Y,C46_Z,C46_W,C47_X,C47_Y,C47_Z
,C47_W,C48_X,C48_Y,C48_Z,C48_W,C49_X,C49_Y,C49_Z,C49_W,C50_X
,C50_Y,C50_Z,C50_W,C51_X,C51_Y,C51_Z,C51_W,C52_X,C52_Y,C52_Z
,C52_W,C53_X,C53_Y,C53_Z,C53_W,C54_X,C54_Y,C54_Z,C54_W,C55_X
,C55_Y,C55_Z,C55_W,C56_X,C56_Y,C56_Z,C56_W,C57_X,C57_Y,C57_Z
,C57_W,C58_X,C58_Y,C58_Z,C58_W,C59_X,C59_Y,C59_Z,C59_W,C60_X
,C60_Y,C60_Z,C60_W,C61_X,C61_Y,C61_Z,C61_W,C62_X,C62_Y,C62_Z
,C62_W,C63_X,C63_Y,C63_Z,C63_W,C64_X,C64_Y,C64_Z,C64_W,C65_X
,C65_Y,C65_Z,C65_W,C66_X,C66_Y,C66_Z,C66_W,C67_X,C67_Y,C67_Z
,C67_W,C68_X,C68_Y,C68_Z,C68_W,C69_X,C69_Y,C69_Z,C69_W,C70_X
,C70_Y,C70_Z,C70_W,C71_X,C71_Y,C71_Z,C71_W,C72_X,C72_Y,C72_Z
,C72_W,C73_X,C73_Y,C73_Z,C73_W,C74_X,C74_Y,C74_Z,C74_W,C75_X
,C75_Y,C75_Z,C75_W,C76_X,C76_Y,C76_Z,C76_W,C77_X,C77_Y,C77_Z
,C77_W,C78_X,C78_Y,C78_Z,C78_W,C79_X,C79_Y,C79_Z,C79_W,C80_X
,C80_Y,C80_Z,C80_W,C81_X,C81_Y,C81_Z,C81_W,C82_X,C82_Y,C82_Z
,C82_W,C83_X,C83_Y,C83_Z,C83_W,C84_X,C84_Y,C84_Z,C84_W,C85_X
,C85_Y,C85_Z,C85_W,C86_X,C86_Y,C86_Z,C86_W,C87_X,C87_Y,C87_Z
,C87_W,C88_X,C88_Y,C88_Z,C88_W,C89_X,C89_Y,C89_Z,C89_W,C90_X
,C90_Y,C90_Z,C90_W,C91_X,C91_Y,C91_Z,C91_W,C92_X,C92_Y,C92_Z
,C92_W,C93_X,C93_Y,C93_Z,C93_W,C94_X,C94_Y,C94_Z,C94_W,C95_X
,C95_Y,C95_Z,C95_W,C96_X,C96_Y,C96_Z,C96_W,C97_X,C97_Y,C97_Z
,C97_W,C98_X,C98_Y,C98_Z,C98_W,C99_X,C99_Y,C99_Z,C99_W)>;

def R600_TReg32 : RegisterClass <"AMDGPU", [f32, i32], 32, (add
    T0_X
,T0_Y,T0_Z,T0_W,T1_X,T1_Y,T1_Z,T1_W,T2_X,T2_Y,T2_Z
,T2_W,T3_X,T3_Y,T3_Z,T3_W,T4_X,T4_Y,T4_Z,T4_W,T5_X
,T5_Y,T5_Z,T5_W,T6_X,T6_Y,T6_Z,T6_W,T7_X,T7_Y,T7_Z
,T7_W,T8_X,T8_Y,T8_Z,T8_W,T9_X,T9_Y,T9_Z,T9_W,T10_X
,T10_Y,T10_Z,T10_W,T11_X,T11_Y,T11_Z,T11_W,T12_X,T12_Y,T12_Z
,T12_W,T13_X,T13_Y,T13_Z,T13_W,T14_X,T14_Y,T14_Z,T14_W,T15_X
,T15_Y,T15_Z,T15_W,T16_X,T16_Y,T16_Z,T16_W,T17_X,T17_Y,T17_Z
,T17_W,T18_X,T18_Y,T18_Z,T18_W,T19_X,T19_Y,T19_Z,T19_W,T20_X
,T20_Y,T20_Z,T20_W,T21_X,T21_Y,T21_Z,T21_W,T22_X,T22_Y,T22_Z
,T22_W,T23_X,T23_Y,T23_Z,T23_W,T24_X,T24_Y,T24_Z,T24_W,T25_X
,T25_Y,T25_Z,T25_W,T26_X,T26_Y,T26_Z,T26_W,T27_X,T27_Y,T27_Z
,T27_W,T28_X,T28_Y,T28_Z,T28_W,T29_X,T29_Y,T29_Z,T29_W,T30_X
,T30_Y,T30_Z,T30_W,T31_X,T31_Y,T31_Z,T31_W,T32_X,T32_Y,T32_Z
,T32_W,T33_X,T33_Y,T33_Z,T33_W,T34_X,T34_Y,T34_Z,T34_W,T35_X
,T35_Y,T35_Z,T35_W,T36_X,T36_Y,T36_Z,T36_W,T37_X,T37_Y,T37_Z
,T37_W,T38_X,T38_Y,T38_Z,T38_W,T39_X,T39_Y,T39_Z,T39_W,T40_X
,T40_Y,T40_Z,T40_W,T41_X,T41_Y,T41_Z,T41_W,T42_X,T42_Y,T42_Z
,T42_W,T43_X,T43_Y,T43_Z,T43_W,T44_X,T44_Y,T44_Z,T44_W,T45_X
,T45_Y,T45_Z,T45_W,T46_X,T46_Y,T46_Z,T46_W,T47_X,T47_Y,T47_Z
,T47_W,T48_X,T48_Y,T48_Z,T48_W,T49_X,T49_Y,T49_Z,T49_W,T50_X
,T50_Y,T50_Z,T50_W,T51_X,T51_Y,T51_Z,T51_W,T52_X,T52_Y,T52_Z
,T52_W,T53_X,T53_Y,T53_Z,T53_W,T54_X,T54_Y,T54_Z,T54_W,T55_X
,T55_Y,T55_Z,T55_W,T56_X,T56_Y,T56_Z,T56_W,T57_X,T57_Y,T57_Z
,T57_W,T58_X,T58_Y,T58_Z,T58_W,T59_X,T59_Y,T59_Z,T59_W,T60_X
,T60_Y,T60_Z,T60_W,T61_X,T61_Y,T61_Z,T61_W,T62_X,T62_Y,T62_Z
,T62_W,T63_X,T63_Y,T63_Z,T63_W,T64_X,T64_Y,T64_Z,T64_W,T65_X
,T65_Y,T65_Z,T65_W,T66_X,T66_Y,T66_Z,T66_W,T67_X,T67_Y,T67_Z
,T67_W,T68_X,T68_Y,T68_Z,T68_W,T69_X,T69_Y,T69_Z,T69_W,T70_X
,T70_Y,T70_Z,T70_W,T71_X,T71_Y,T71_Z,T71_W,T72_X,T72_Y,T72_Z
,T72_W,T73_X,T73_Y,T73_Z,T73_W,T74_X,T74_Y,T74_Z,T74_W,T75_X
,T75_Y,T75_Z,T75_W,T76_X,T76_Y,T76_Z,T76_W,T77_X,T77_Y,T77_Z
,T77_W,T78_X,T78_Y,T78_Z,T78_W,T79_X,T79_Y,T79_Z,T79_W,T80_X
,T80_Y,T80_Z,T80_W,T81_X,T81_Y,T81_Z,T81_W,T82_X,T82_Y,T82_Z
,T82_W,T83_X,T83_Y,T83_Z,T83_W,T84_X,T84_Y,T84_Z,T84_W,T85_X
,T85_Y,T85_Z,T85_W,T86_X,T86_Y,T86_Z,T86_W,T87_X,T87_Y,T87_Z
,T87_W,T88_X,T88_Y,T88_Z,T88_W,T89_X,T89_Y,T89_Z,T89_W,T90_X
,T90_Y,T90_Z,T90_W,T91_X,T91_Y,T91_Z,T91_W,T92_X,T92_Y,T92_Z
,T92_W,T93_X,T93_Y,T93_Z,T93_W,T94_X,T94_Y,T94_Z,T94_W,T95_X
,T95_Y,T95_Z,T95_W,T96_X,T96_Y,T96_Z,T96_W,T97_X,T97_Y,T97_Z
,T97_W,T98_X,T98_Y,T98_Z,T98_W,T99_X,T99_Y,T99_Z,T99_W,T100_X
,T100_Y,T100_Z,T100_W,T101_X,T101_Y,T101_Z,T101_W,T102_X,T102_Y,T102_Z
,T102_W,T103_X,T103_Y,T103_Z,T103_W,T104_X,T104_Y,T104_Z,T104_W,T105_X
,T105_Y,T105_Z,T105_W,T106_X,T106_Y,T106_Z,T106_W,T107_X,T107_Y,T107_Z
,T107_W,T108_X,T108_Y,T108_Z,T108_W,T109_X,T109_Y,T109_Z,T109_W,T110_X
,T110_Y,T110_Z,T110_W,T111_X,T111_Y,T111_Z,T111_W,T112_X,T112_Y,T112_Z
,T112_W,T113_X,T113_Y,T113_Z,T113_W,T114_X,T114_Y,T114_Z,T114_W,T115_X
,T115_Y,T115_Z,T115_W,T116_X,T116_Y,T116_Z,T116_W,T117_X,T117_Y,T117_Z
,T117_W,T118_X,T118_Y,T118_Z,T118_W,T119_X,T119_Y,T119_Z,T119_W,T120_X
,T120_Y,T120_Z,T120_W,T121_X,T121_Y,T121_Z,T121_W,T122_X,T122_Y,T122_Z
,T122_W,T123_X,T123_Y,T123_Z,T123_W,T124_X,T124_Y,T124_Z,T124_W,T125_X
,T125_Y,T125_Z,T125_W,T126_X,T126_Y,T126_Z,T126_W,T127_X,T127_Y,T127_Z
,T127_W)>;

def R600_TReg32_X : RegisterClass <"AMDGPU", [f32, i32], 32, (add
    T0_X
,T1_X,T2_X,T3_X,T4_X,T5_X,T6_X,T7_X,T8_X,T9_X,T10_X
,T11_X,T12_X,T13_X,T14_X,T15_X,T16_X,T17_X,T18_X,T19_X,T20_X
,T21_X,T22_X,T23_X,T24_X,T25_X,T26_X,T27_X,T28_X,T29_X,T30_X
,T31_X,T32_X,T33_X,T34_X,T35_X,T36_X,T37_X,T38_X,T39_X,T40_X
,T41_X,T42_X,T43_X,T44_X,T45_X,T46_X,T47_X,T48_X,T49_X,T50_X
,T51_X,T52_X,T53_X,T54_X,T55_X,T56_X,T57_X,T58_X,T59_X,T60_X
,T61_X,T62_X,T63_X,T64_X,T65_X,T66_X,T67_X,T68_X,T69_X,T70_X
,T71_X,T72_X,T73_X,T74_X,T75_X,T76_X,T77_X,T78_X,T79_X,T80_X
,T81_X,T82_X,T83_X,T84_X,T85_X,T86_X,T87_X,T88_X,T89_X,T90_X
,T91_X,T92_X,T93_X,T94_X,T95_X,T96_X,T97_X,T98_X,T99_X,T100_X
,T101_X,T102_X,T103_X,T104_X,T105_X,T106_X,T107_X,T108_X,T109_X,T110_X
,T111_X,T112_X,T113_X,T114_X,T115_X,T116_X,T117_X,T118_X,T119_X,T120_X
,T121_X,T122_X,T123_X,T124_X,T125_X,T126_X,T127_X)>;
    
def R600_Reg32 : RegisterClass <"AMDGPU", [f32, i32], 32, (add
    R600_TReg32,
    R600_CReg32,
    ZERO, HALF, ONE, ONE_INT, PV_X, ALU_LITERAL_X, NEG_ONE, NEG_HALF)>;

def R600_Predicate : RegisterClass <"AMDGPU", [i32], 32, (add
    PRED_SEL_OFF, PRED_SEL_ZERO, PRED_SEL_ONE)>;

def R600_Predicate_Bit: RegisterClass <"AMDGPU", [i32], 32, (add
    PREDICATE_BIT)>;

def R600_Reg128 : RegisterClass<"AMDGPU", [v4f32, v4i32], 128, (add
    T0_XYZW
,T1_XYZW,T2_XYZW,T3_XYZW,T4_XYZW,T5_XYZW,T6_XYZW,T7_XYZW,T8_XYZW,T9_XYZW,T10_XYZW
,T11_XYZW,T12_XYZW,T13_XYZW,T14_XYZW,T15_XYZW,T16_XYZW,T17_XYZW,T18_XYZW,T19_XYZW,T20_XYZW
,T21_XYZW,T22_XYZW,T23_XYZW,T24_XYZW,T25_XYZW,T26_XYZW,T27_XYZW,T28_XYZW,T29_XYZW,T30_XYZW
,T31_XYZW,T32_XYZW,T33_XYZW,T34_XYZW,T35_XYZW,T36_XYZW,T37_XYZW,T38_XYZW,T39_XYZW,T40_XYZW
,T41_XYZW,T42_XYZW,T43_XYZW,T44_XYZW,T45_XYZW,T46_XYZW,T47_XYZW,T48_XYZW,T49_XYZW,T50_XYZW
,T51_XYZW,T52_XYZW,T53_XYZW,T54_XYZW,T55_XYZW,T56_XYZW,T57_XYZW,T58_XYZW,T59_XYZW,T60_XYZW
,T61_XYZW,T62_XYZW,T63_XYZW,T64_XYZW,T65_XYZW,T66_XYZW,T67_XYZW,T68_XYZW,T69_XYZW,T70_XYZW
,T71_XYZW,T72_XYZW,T73_XYZW,T74_XYZW,T75_XYZW,T76_XYZW,T77_XYZW,T78_XYZW,T79_XYZW,T80_XYZW
,T81_XYZW,T82_XYZW,T83_XYZW,T84_XYZW,T85_XYZW,T86_XYZW,T87_XYZW,T88_XYZW,T89_XYZW,T90_XYZW
,T91_XYZW,T92_XYZW,T93_XYZW,T94_XYZW,T95_XYZW,T96_XYZW,T97_XYZW,T98_XYZW,T99_XYZW,T100_XYZW
,T101_XYZW,T102_XYZW,T103_XYZW,T104_XYZW,T105_XYZW,T106_XYZW,T107_XYZW,T108_XYZW,T109_XYZW,T110_XYZW
,T111_XYZW,T112_XYZW,T113_XYZW,T114_XYZW,T115_XYZW,T116_XYZW,T117_XYZW,T118_XYZW,T119_XYZW,T120_XYZW
,T121_XYZW,T122_XYZW,T123_XYZW,T124_XYZW,T125_XYZW,T126_XYZW,T127_XYZW)>
{
  let CopyCost = -1;
}

